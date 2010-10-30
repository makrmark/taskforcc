class AddChangeProfileToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :organisation, :string
    add_column :users, :country, :string
    add_column :users, :job_title, :string
    add_column :users, :phone_number, :string
  end

  def self.down
    remove_column :users, :phone_number
    remove_column :users, :job_title
    remove_column :users, :country
    remove_column :users, :organisation
  end
end
