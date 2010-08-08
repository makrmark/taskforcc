require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :collaborations_users
  has_many :collaborations, :through => :collaborations_users

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
  
end
