class AddVersionToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :version, :integer, :null => false, :default => 1
  end

  def self.down
    remove_column :tasks, :version
  end
end
