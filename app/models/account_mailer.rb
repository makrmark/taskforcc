class AccountMailer < ActionMailer::Base

  # Welcome a user to Taskforcc
  def welcome(user)
    subject    'Welcome to taskfor.cc'
    recipients user.email
    bcc        "mark@taskfor.cc"
    from       "Taskforcc <notifications@taskfor.cc>"
    sent_on    Time.now
    
    body       :greeting => 'Hi,', :user => user
  end

  # Invite a user to Taskforcc
  def invite_to_service(user, invited_by)
    subject    'Welcome to taskfor.cc'
    recipients user.email
    bcc        'mark@taskfor.cc'
    from       "Taskforcc <notifications@taskfor.cc>"
    sent_on    Time.now
    
    body       :user => user, :invited_by => invited_by
  end    

  # Invite a user to a collaboration
  def invite_to_collaborate(user, invited_by, collaboration)
    subject    "Welcome to: '#{collaboration.subject}'"
    recipients user.email
    bcc        'mark@taskfor.cc'
    from       "Taskforcc <notifications@taskfor.cc>"
    sent_on    Time.now
    
    body  :invited_by => invited_by, :collaboration => collaboration
  end    

end
