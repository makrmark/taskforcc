class CreateCollaborations < ActiveRecord::Migration
  def self.up
    create_table :collaborations do |t|
      t.string :subject
      t.text :description
      t.string :status
      t.integer :created_by

      t.timestamps
    end
  end

  def self.down
    drop_table :collaborations
  end
end
