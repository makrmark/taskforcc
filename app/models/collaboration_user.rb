class CollaborationUser < ActiveRecord::Base
  set_table_name "collaborations_users"

  belongs_to :user
  belongs_to :collaboration

end
