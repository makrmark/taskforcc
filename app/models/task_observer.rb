class TaskObserver < ActiveRecord::Observer
  def after_create(task)
    TaskMailer.deliver_notify_created(task)
  end
  def after_update(task)
    TaskMailer.deliver_notify_updated(task)
    TaskMailer.deliver_notify_watchers(task)
  end
end