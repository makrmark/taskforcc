class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :task_id
      t.integer :user_id
      t.string :comment

      t.timestamps
    end
    add_index :comments, :task_id
    add_index :comments, :user_id
  end

  def self.down
    drop_table :comments
  end
end
