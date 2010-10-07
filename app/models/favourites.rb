class Favourites < ActiveRecord::Base
  belongs_to :users
  belongs_to :collaborations
  belongs_to :tasks
  
end
