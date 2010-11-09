class AddIsSystemToCollaborations < ActiveRecord::Migration
  def self.up
    add_column :collaborations, :is_system, :boolean, :default => false
  end

  def self.down
    remove_column :collaborations, :is_system
  end
end
