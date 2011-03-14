class Activity < ActiveRecord::Base
  belongs_to :user_updated_by,
    :class_name => 'User',
    :primary_key => :id,
    :foreign_key => :updated_by
    
  belongs_to :collaboration
  belongs_to :topic
  belongs_to :task
  belongs_to :user

  has_many :collaboration_user,
    :primary_key => :updated_by,
    :foreign_key => :user_id
  has_many :acts
  
end
