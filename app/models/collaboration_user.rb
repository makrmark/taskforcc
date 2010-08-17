class CollaborationUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :collaboration

  validates_presence_of :collaboration_id, :user_id

  # not sure why, but this doesn't seem to work
  validates_associated :user
  validates_associated :collaboration

  # used to lookup a user by email
  attr_accessor :email

end
