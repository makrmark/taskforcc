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
    TaskMailer.deliver_notify_created(task)
  end
   
  def after_update(task)
    TaskMailer.deliver_notify_updated(task)
    TaskMailer.deliver_notify_watchers(task)
  end
end