class AddIndexesToUsers < ActiveRecord::Migration
  def self.up
    add_index :users, :full_name
    add_index :users, :email
  end

  def self.down
    remove_index :users, :index_users_on_full_name
    remove_index :users, :index_users_on_email
  end
end
