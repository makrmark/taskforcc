class AddCollaborationIdToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :collaboration_id, :integer
    add_index :tasks, :collaboration_id
  end

  def self.down
    remove_index :tasks, :collaboration_id
    remove_column :tasks, :collaboration_id
  end
end
