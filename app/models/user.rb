require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :collaboration_users
  has_many :collaborations, 
    :through => :collaboration_users,
    :include => :counters,
    :order => "IS_SYSTEM DESC, SUBJECT ASC"
  has_many :comments
  has_many :favourites

  # User -> CollaborationUsers -> Tasks (collaboration_id)
  # See: CollaborationUserTask model class
  has_many :collaboration_user_tasks

  # To get all tasks for a user based on their role
  # task.collaboration_id == collaboration_user.collaboration_id)
  # and ( collaboration_user.role <> Restricted  ||  task.assigned_to == collaboration_user.user_id)
  has_many :tasks,
    :through => :collaboration_user_tasks,
    :order   => "updated_at DESC",
    :conditions => "( collaboration_users.role <> 'Restricted' OR tasks.assigned_to = collaboration_users.user_id )"

  has_many :collaborations_created_by,
    :class_name => 'Collaboration',
    :foreign_key => 'created_by'

  has_many :tasks_created_by,
    :class_name => 'Task',
    :foreign_key => 'created_by'
    
  has_many :tasks_assigned_to,
    :class_name => 'Task',
    :foreign_key => 'assigned_to'

  named_scope :status_filter, lambda { |t|
    { :conditions => { :status => t } }
  }
    
  def find_tasks(p)
    self.tasks.title_filter(p[:title] || "").status_filter(p[:include_status])
  end
  
  # http://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html
  validates_presence_of :full_name, :email

  attr_accessor :password_confirmation, :email_confirmation
  validates_presence_of :password, :unless => :skip_password_check?

  validates_confirmation_of :password, :email
  validate :password_non_blank
  
  # http://www.regular-expressions.info/email.html
  validates_format_of :email, :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  validates_uniqueness_of :email

  # http://www.sitepoint.com/blogs/2008/10/06/timezones-in-rails-21/
  def self.authenticate(email, password)
    user = self.find_by_email(email)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end

  # a virtual attribute
  def password
    @password
  end  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end
  
  def skip_password_check?
    @skip_password_check
  end
  def skip_password_check=(skip)
    @skip_password_check = skip
  end

  # Invite a user to taskfor.cc
  def self.invite(email, invited_by)
      user_to_invite = User.new( :email => email,
        :full_name => email[/^[^@]*/] )
      user_to_invite.password = self.random_string(8)
      user_to_invite.change_pass = true
      user_to_invite.save

      # Sent the welcome email for the new user
      AccountMailer.deliver_invite_to_service(user_to_invite, invited_by)
      
      return user_to_invite
  end
  
  def self.random_password
    random_string(8)
  end

  # once the user creation is confirmed, send the welcome message  
  # normally triggered from after_commit callback
  def send_welcome
      AccountMailer.deliver_welcome(self)
  end
  def send_recover
    AccountMailer.deliver_recover(self)
  end

  def can_create_task?(task)
    cu = CollaborationUser.find(:first, 
      :conditions => ["collaboration_id = ? AND user_id = ?", task.collaboration_id, self.id])

    # TODO: Should use the State Transitions in Task here, but it's more expensive
    cu.role.eql?('Observer') ? false : true;
  end
  
protected

private
  
  def password_non_blank
    errors.add(:password, "Missing password") if hashed_password.blank?
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "collab" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def send_new_password
    new_pass = User.random_string(10)
    self.password = self.password_confirmation = new_pass
    self.save
    Notifications.deliver_forgot_password(self.email, self.login, new_pass)
  end

  # http://www.aidanf.net/rails_user_authentication_tutorial
  def self.random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
  
end
