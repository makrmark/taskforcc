class CreateCollaborationUsers < ActiveRecord::Migration
  def self.up
    create_table :collaboration_users do |t|
      t.integer :collaboration_id
      t.integer :user_id
      t.boolean :manager

      t.timestamps
    end
  end

  def self.down
    drop_table :collaboration_users
  end
end
