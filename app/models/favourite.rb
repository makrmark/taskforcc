class Favourite < ActiveRecord::Base
  belongs_to :user
  belongs_to :collaboration
  belongs_to :task
  
  named_scope :user_filter, lambda { |t| 
    { :conditions => { :user_id => t } } 
  }
end
