class TaskMailer < ActionMailer::Base

  def notify_created(task)
    subject    "Task Updated: #{task.title}"
    # don't notify the person doing the creating
    unless task.assigned_to == task.created_by
      recipients task.user_assigned_to.email
    end
    from       '"Taskforcc" <notifications@taskfor.cc>'
    sent_on    Time.now    
    body       :task => task
  end

  def notify_updated(task)
    
    subject    "Assigned Task Updated: #{task.title}"
    # don't notify the person doing the update
    unless task.assigned_to == task.updated_by
      recipients task.user_assigned_to.email
    end
    from       '"Taskforcc" <notifications@taskfor.cc>'
    sent_on    Time.now
    body       :task => task
  end

  def notify_watchers(task)    
    watchers = []    
    task.favourites.each do |f|
      # don't notify the user assigned to (who gets notified by default)
      # or the user who did the edit (who presumably knows what they've done)
      unless f.user_id == task.assigned_to || f.user_id == task.updated_by
        watchers << f.user.email 
      end
    end
    
    subject    "Watched Task Updated: #{task.title}"
    recipients watchers
    from       '"Taskforcc" <notifications@taskfor.cc>'
    sent_on    Time.now
    body       :task => task
  end

end
