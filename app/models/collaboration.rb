class Collaboration < ActiveRecord::Base
  has_many :tasks
  has_many :collaboration_users
  has_many :topics
  has_many :users, :through => :collaboration_users
  has_one  :unfiled_topic, 
    :class_name => 'Topic', 
    :conditions => "system_name ='unfiled'"

  belongs_to :user_created_by,
    :class_name => 'User',
    :primary_key => 'id',
    :foreign_key => 'created_by'

  validates_presence_of :subject, :status, :created_by

  validates_inclusion_of :status, 
    :in => %w{Open On-Hold Closed}, 
    :message => "should be Open, On-Hold, or Closed"
  
end
