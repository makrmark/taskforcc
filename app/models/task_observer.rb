class TaskObserver < ActiveRecord::Observer
  # http://ar.rubyonrails.org/classes/ActiveRecord/Dirty.html
  # If a Task status has changed, make sure it is assigned to the correct user
  def before_update(task)
    if task.status_changed?
      case task.status
      when 'Resolved', 'Rejected', 'Closed'
        task.assigned_to = task.topic.controller
      when 'Accepted'
        task.assigned_to = task.updated_by
      end
    end             
  end

  def after_create(task)

    increment_counters(task)
    
    add_task_created_activity(task)
    
    TaskMailer.deliver_notify_created(task)
  end
  
  def after_update(task)

    # if anything of relevance was changed
    if (task.changed & ['collaboration_id', 'topic_id', 'assigned_to', 'status']).length > 0
      update_counters(task)
    end

    add_task_updated_activity(task)

    TaskMailer.deliver_notify_updated(task)
    TaskMailer.deliver_notify_watchers(task)
  end


private

  def add_task_updated_activity(task)
    add_task_activity(task, 'updated')
  end
  def add_task_created_activity(task)
    add_task_activity(task, 'created')
  end
  def add_task_activity(task, action)
    activity = Activity.find_by_task_id(task.id)

    # check if we should keep the last or create new activity
    tnow = Time.new
    
    activity.logger.debug("Now: #{tnow}, Updated At: #{activity.updated_at}") unless activity.nil?
    
    if activity.nil? ||
      activity.updated_by != task.updated_by ||
      tnow - activity.updated_at > 30
      
      activity = Activity.new(
        :related_class => 'Task',
        :action => action,
        :task_id => task.id
      )
    end

    activity.collaboration_id = task.collaboration_id
    activity.topic_id = task.topic_id
    activity.user_id = task.assigned_to
    activity.updated_by = task.updated_by
    activity.save!

    add_task_acts(task, activity)
  end
  
  def add_task_acts(task, activity)    
    task.changes.each do |name, change|
      add_task_act(task, activity, name, *change) if Task.auditable_attribute?(name)
    end
  end
  
  def add_task_act(task, activity, attribute_name, old_val, new_val)
    
    activity.logger.debug("adding audit record for #{attribute_name}")
    act = Act.new(
      :activity_id => activity.id,
      :attribute_name => attribute_name,
      :attribute_type => Task.auditable_attribute_type(attribute_name)
    )

    case Task.auditable_attribute_type(attribute_name)
    when 'string'
      act.string_val = new_val
      act.string_val_was = old_val
    when 'integer'
      act.integer_val  = new_val
      act.integer_val_was = old_val
    when 'datetime'
      act.datetime_val = new_val
      act.datetime_val_was = old_val      
    when 'integer-string'
      act.integer_val  = new_val
      act.integer_val_was = old_val
      
      act.string_val = task.auditable_attribute_string_val(attribute_name, new_val)
      act.string_val_was = task.auditable_attribute_string_val(attribute_name, old_val) unless old_val.nil?
    end

    act.save!

  end

  def update_counters(task)

    # Check if some of the dimensional data has changed
    if (task.changed & %w{collaboration_id topic_id assigned_to}).length > 0

      open_decrement = task.status_was.eql?('Closed') ? 0 : 1

      # decrement the old dimensional record (this should always exist)
      c = Counter.update_all(
        "cnt_#{task.status_was} = cnt_#{task.status_was} - 1, "+
        "cnt_total_open = cnt_total_open - #{open_decrement}, " +
        "cnt_total = cnt_total - 1 ",
        ["collaboration_id = ? AND user_id = ? AND topic_id = ? ", 
          task.collaboration_id_was,
          task.assigned_to_was,
          task.topic_id_was]
      )

      increment_counters(task)

    else
      # if only the status was updated, just update the relevant statuses
      open_increment = get_open_increment(task)

      Counter.update_all(
        "cnt_#{task.status} = cnt_#{task.status} + 1, " +
        "cnt_#{task.status_was} = cnt_#{task.status_was} - 1, " +
        "cnt_total_open = cnt_total_open + #{open_increment} ",
        ["collaboration_id = ? AND user_id = ? AND topic_id = ? ", 
          task.collaboration_id,
          task.assigned_to,
          task.topic_id]
      )
      
    end
  end
  
  def increment_counters(task)
    # increment the counter on the new dimensions
    
    open_increment = task.status.eql?('Closed') ? 0 : 1;
    
    cnt = Counter.update_all(
      "cnt_#{task.status} = cnt_#{task.status} + 1, " + 
      "cnt_total_open = cnt_total_open + #{open_increment}, " +
      "cnt_total = cnt_total + 1 ",
      ["collaboration_id = ? AND user_id = ? AND topic_id = ? ", 
        task.collaboration_id,
        task.assigned_to,
        task.topic_id]
    )
    
    # if the new dimensions did not already exist - create them
    if cnt < 1
      c = Counter.new(
        :collaboration_id => task.collaboration_id,
        :user_id => task.assigned_to,
        :topic_id => task.topic_id,
        :cnt_total_open => open_increment,
        :cnt_total => 1
      ) 
      c.write_attribute("cnt_#{task.status}", 1)
      c.save!
    end
  end
    
  def get_open_increment(task)    
    open_increment = 0
    if task.status.eql?('Closed')
      unless task.status_was.eql?('Closed')
        open_increment = -1
      end
    elsif task.status_was.eql?('Closed')
      open_increment = 1
    end
    return open_increment
  end  
  
end