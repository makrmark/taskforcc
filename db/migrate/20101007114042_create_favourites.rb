class CreateFavourites < ActiveRecord::Migration
  def self.up
    create_table :favourites do |t|
      t.integer :task_id
      t.integer :user_id
      t.integer :collaboration_id

      t.timestamps

    end
    add_index :favourites, :task_id
    add_index :favourites, :user_id
    add_index :favourites, :collaboration_id
  end

  def self.down
    drop_table :favourites
  end
end
