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

  # See: CollaborationUserTask model class
  belongs_to :collaboration_user_task,
    :primary_key => 'collaboration_id',
    :foreign_key => 'collaboration_id'

  named_scope :collaboration_filter, lambda { |t|
    { :conditions => { :collaboration_id => t } }
  }

  named_scope :topic_filter, lambda { |t|
    { :conditions => { :topic_id => t } }
  }

  named_scope :user_filter, lambda { |t|
    { :conditions => { :user_id => t } }
  }

  named_scope :favourite_filter, lambda { |t|
    { :conditions => { :task_id => t } }
  }

  named_scope :activities_filter, lambda { |t|
    { :conditions => { :id => t } }
  }
  
  named_scope :latest_filter, lambda { |t|
    { :conditions => { :is_latest => true } }
  }

  named_scope :action_filter, lambda { |t|
    { :conditions => { :action => t } }
  }
  
end
