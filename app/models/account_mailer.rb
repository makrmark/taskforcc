class AccountMailer < ActionMailer::Base

  def welcome(user)
    subject    'Welcome to taskfor.cc'
    recipients user.email
    from       'no-reply@taskfor.cc'
    sent_on    Time.now
    
    body       :greeting => 'Hi,'
  end

  # Invite a user to take part in a collaboration
  def invite(user, invited_by, collaboration)
    subject    'Invitation to taskfor.cc'
    recipients user.email
    from       'no-reply@taskfor.cc'
    sent_on    Time.now
    
    body  :invited_by => invited_by, :collaboration => collaboration
  end    

end
