require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :collaboration_users
  has_many :collaborations, 
    :through => :collaboration_users,
    :order => "SUBJECT ASC"
  has_many :comments
  has_many :favourites

  # User -> Collaborations -> Tasks (collaboration_id)
  # TODO: can we do this using more standard syntax?
  has_many :collaboration_tasks, 
    :class_name => 'Task',
    :finder_sql => 'SELECT DISTINCT t.* ' +
      ' FROM collaboration_users cu, tasks t ' +
      ' WHERE cu.user_id = #{id} ' +
      ' AND t.collaboration_id = cu.collaboration_id ' +
      ' GROUP BY t.updated_at '
      ' ORDER BY t.updated_at DESC ;' # TODO: index on updated

  has_many :collaborations_created_by,
    :class_name => 'Collaboration',
    :foreign_key => 'created_by'

  has_many :tasks_created_by,
    :class_name => 'Task',
    :foreign_key => 'created_by'
    
  has_many :tasks_assigned_to,
    :class_name => 'Task',
    :foreign_key => 'assigned_to'
  
  validates_presence_of :full_name, :email
  validates_length_of :full_name, :minimum => 2

  # from here: http://www.regular-expressions.info/email.html
  validates_format_of :email, :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  validates_confirmation_of :email
  validates_uniqueness_of :email

  attr_accessor :password_confirmation
  validates_confirmation_of :password  
  validate :password_non_blank

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

  # http://www.aidanf.net/rails_user_authentication_tutorial
  def self.random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
  def send_new_password
    new_pass = User.random_string(10)
    self.password = self.password_confirmation = new_pass
    self.save
    Notifications.deliver_forgot_password(self.email, self.login, new_pass)
  end
  
end
