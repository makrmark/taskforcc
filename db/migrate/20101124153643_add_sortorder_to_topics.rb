class AddSortorderToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :sortorder, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :topics, :sortorder
  end
end
