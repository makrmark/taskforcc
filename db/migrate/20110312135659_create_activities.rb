class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :updated_by
      t.string  :related_class, :null => false
      t.string  :action, :null => false, :default => 'create'
      t.string  :label
      t.integer :collaboration_id, :null => false
      t.integer :task_id
      t.integer :user_id
      t.integer :topic_id

      t.timestamps
    end

    add_index :activities, :updated_by
    add_index :activities, :collaboration_id
    add_index :activities, :updated_at
    
  end

  def self.down
    drop_table :activities
  end
end
