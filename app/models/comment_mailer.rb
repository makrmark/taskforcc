class CommentMailer < ActionMailer::Base

  def notify_all(comment)
    task = comment.task
    
    commenters = []
    task.comments.each do |c|
      commenters << c.user.email
    end

    watchers = []    
    task.favourites.each do |f|
      watchers << f.user.email
    end
    
    all_recipients = commenters | watchers | [task.user_assigned_to.email]

    subject    "New Task Comments: #{task.title}"
    recipients all_recipients
    from       "Taskforcc <notifications@taskfor.cc>"
    sent_on    Time.now
    body       :comment => comment, :task => task
  end
  
end
