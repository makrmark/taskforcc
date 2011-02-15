class AddStatusToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :status, :string, :null => false, :default => "Invited"

    User.reset_column_information
    User.find(:all).each do |p|
      p.update_attribute :status, "Active"
    end
    
    add_index :users, :status
  end

  def self.down
    remove_column :users, :status
  end
end
