class AddUpdatedByToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :updated_by, :integer
  end

  def self.down
    remove_column :tasks, :updated_by
  end
end
