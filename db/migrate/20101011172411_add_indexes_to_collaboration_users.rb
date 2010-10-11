class AddIndexesToCollaborationUsers < ActiveRecord::Migration
  def self.up
      add_index :collaboration_users, :collaboration_id
      add_index :collaboration_users, :user_id
  end

  def self.down
      remove_index :collaboration_users, :index_collaboration_users_on_collaboration_id
      remove_index :collaboration_users, :index_collaboration_users_on_user_id
  end
end
