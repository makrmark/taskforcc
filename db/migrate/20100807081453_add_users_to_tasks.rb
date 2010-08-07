class AddUsersToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :created_by, :integer
    add_column :tasks, :assigned_to, :integer
  end

  def self.down
    remove_column :tasks, :assigned_to
    remove_column :tasks, :created_by
  end
end
