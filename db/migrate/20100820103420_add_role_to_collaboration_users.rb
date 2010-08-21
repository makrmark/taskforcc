class AddRoleToCollaborationUsers < ActiveRecord::Migration
  def self.up
    add_column :collaboration_users, :role, :string, :null => false, :default => 'Team'
    remove_column :collaboration_users, :manager
  end

  def self.down
    remove_column :collaboration_users, :role
  end
end
