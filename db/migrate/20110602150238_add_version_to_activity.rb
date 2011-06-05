class AddVersionToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :version, :integer, :null => false, :default => 1
  end

  def self.down
    remove_column :activities, :version
  end
end
