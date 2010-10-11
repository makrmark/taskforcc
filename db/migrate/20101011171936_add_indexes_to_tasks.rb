class AddIndexesToTasks < ActiveRecord::Migration
  def self.up
    add_index :tasks, :created_at
    add_index :tasks, :updated_at
    add_index :tasks, :created_by    
    add_index :tasks, :updated_by
    add_index :tasks, :assigned_to
    add_index :tasks, :topic_id
    add_index :tasks, :status
    
  end

  def self.down
    remove_index :tasks, :index_tasks_on_created_at
    remove_index :tasks, :index_tasks_on_updated_at
    remove_index :tasks, :index_tasks_on_created_by    
    remove_index :tasks, :index_tasks_on_updated_by
    remove_index :tasks, :index_tasks_on_assigned_to
    remove_index :tasks, :index_tasks_on_topic_id
    remove_index :tasks, :index_tasks_on_status
  end
end
