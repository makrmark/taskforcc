class AddSystemFieldsToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :is_system, :boolean, :default => false, :null => false
    add_column :topics, :system_name, :string
  end

  def self.down
    remove_column :topics, :system_name
    remove_column :topics, :is_system
  end
end
