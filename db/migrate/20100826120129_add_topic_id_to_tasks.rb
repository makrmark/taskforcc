class AddTopicIdToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :topic_id, :integer
  end

  def self.down
    remove_column :tasks, :topic_id
  end
end
