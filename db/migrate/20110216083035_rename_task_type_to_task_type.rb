class RenameTaskTypeToTaskType < ActiveRecord::Migration
  def self.up
    rename_column :tasks, :type, :task_type
  end

  def self.down
    rename_column :tasks, :task_type, :type
  end
end
