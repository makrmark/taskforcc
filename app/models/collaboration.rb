class Collaboration < ActiveRecord::Base
  has_many :collaborations_users  
  has_many :users, :through => :collaborations_users

  belongs_to :user_created_by,
    :class_name => 'User',
    :primary_key => 'id',
    :foreign_key => 'created_by'

  has_many :users, :through => :collaboration_users

  validates_presence_of :subject, :description, :status, :created_by

  validates_inclusion_of :status, 
    :in => %w{In-Progress On-Hold Cancelled Completed}, 
    :message => "should be In-Progress, On-Hold, Cancelled, or Completed"

end
