class Counter < ActiveRecord::Base  
  has_one :collaboration
  has_one :topic
  has_one :user

  named_scope :collaboration_filter, lambda { |t|
    { :conditions => { :collaboration_id => t } }
  }
  
  named_scope :topic_filter, lambda { |t|
    { :conditions => { :topic_id => t } }
  }
  
  named_scope :user_filter, lambda { |t|
    { :conditions => { :user_id => t } }
  }

end
