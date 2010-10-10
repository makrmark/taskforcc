class Favourite < ActiveRecord::Base
  belongs_to :user
  belongs_to :collaboration
  belongs_to :task
end
