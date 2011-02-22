class Counter < ActiveRecord::Base  
  has_one :collaboration
  has_one :topic
  has_one :user
  
end
