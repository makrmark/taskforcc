class AddIsLatestToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :is_latest, :boolean, :null => false, :default => false
    add_index :activities, :is_latest
  end

  def self.down
    remove_column :activities, :is_latest
  end
end
