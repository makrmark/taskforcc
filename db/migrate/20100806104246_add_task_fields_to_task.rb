class AddTaskFieldsToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :title, :string
    add_column :tasks, :description, :text
    add_column :tasks, :type, :string, :null => false, :default => "Task"
    add_column :tasks, :status, :string, :null => false, :default => "New"
  end

  def self.down
    remove_column :tasks, :title
    remove_column :tasks, :description
    remove_column :tasks, :type
    remove_column :tasks, :status
  end
end
