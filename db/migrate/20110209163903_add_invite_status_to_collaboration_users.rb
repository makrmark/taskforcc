class AddInviteStatusToCollaborationUsers < ActiveRecord::Migration
  def self.up
    add_column :collaboration_users, :status, :string, :null => false, :default => "Invited"
    
    CollaborationUser.reset_column_information
    CollaborationUser.find(:all).each do |p|
      p.update_attribute :status, "Accepted"
    end
    
    add_index :collaboration_users, :status
  end

  def self.down
    remove_column :collaboration_users, :status
  end
end
