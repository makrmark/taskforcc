class RemoveStatusFromCollaborationUsers < ActiveRecord::Migration
  def self.up
    remove_column :collaboration_users, :status
  end

  def self.down
  end
end
