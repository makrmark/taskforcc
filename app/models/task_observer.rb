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
    
    TaskMailer.deliver_notify_created(task)
  end
  
  def after_update(task)

    # if anything of relevance was changed
    if (task.changed & ['collaboration_id', 'topic_id', 'assigned_to', 'status']).length > 0
      update_counters(task)
    end

    TaskMailer.deliver_notify_updated(task)
    TaskMailer.deliver_notify_watchers(task)
  end


private

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