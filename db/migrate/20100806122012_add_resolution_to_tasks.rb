class AddResolutionToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :resolution, :string, :null => false, :default => "Unresolved"
  end

  def self.down
    remove_column :tasks, :resolution
  end
end
