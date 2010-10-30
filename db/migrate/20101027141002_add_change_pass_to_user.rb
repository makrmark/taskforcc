class AddChangePassToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :change_pass, :boolean, :default => false
  end

  def self.down
    remove_column :users, :change_pass
  end
end
