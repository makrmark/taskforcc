class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    CommentMailer.deliver_notify_all(comment)
  end
end