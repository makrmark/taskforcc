class AddIndexesToTopics < ActiveRecord::Migration
  def self.up
    add_index :topics, :controller
    add_index :topics, :collaboration_id
    add_index :topics, :is_system
  end

  def self.down
    remove_index :topics, :index_topics_on_controller
    remove_index :topics, :index_topics_on_collaboration_id
    remove_index :topics, :index_topics_on_is_system
  end
end
