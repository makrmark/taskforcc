class TaskMailer < ActionMailer::Base

  def notify_created(task)
    subject    "Task Updated: #{task.title}"
    recipients task.user_assigned_to.email
    from       "Taskforcc <notifications@taskfor.cc>"
    sent_on    Time.now    
    body       :task => task
  end

  def notify_updated(task)
    subject    "Assigned Task Updated: #{task.title}"
    recipients task.user_assigned_to.email
    from       "Taskforcc <notifications@taskfor.cc>"
    sent_on    Time.now
    body       :task => task
  end

  def notify_watchers(task)    
    watchers = []    
    task.favourites.each do |f|
      # don't notify the user assigned to (who gets notified by default)
      watchers << f.user.email unless f.user_id == task.assigned_to
    end
    
    subject    "Watched Task Updated: #{task.title}"
    recipients watchers
    from       "Taskforcc <notifications@taskfor.cc>"
    sent_on    Time.now
    body       :task => task
  end

end
