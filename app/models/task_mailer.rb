class TaskMailer < ActionMailer::Base

  def notify_created(task)
    subject    "Task Updated: #{task.title}"
    recipients task.user_assigned_to.email
    from       'task-notifier@taskfor.cc'
    sent_on    Time.now    
    body       :task => task
  end

  def notify_updated(task)
    subject    "Task Updated: #{task.title}"
    recipients task.user_assigned_to.email
    from       'task-notifier@taskfor.cc'
    sent_on    Time.now
    body       :task => task
  end

end
