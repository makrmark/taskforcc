class Comment < ActiveRecord::Base
  belongs_to :task
  belongs_to :user

  validates_presence_of :user_id, :task_id, :comment 
  validates_associated :task => "could not be found"  
  validates_associated :user => "could not be found"
  
end
