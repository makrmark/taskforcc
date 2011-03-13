class CreateActs < ActiveRecord::Migration
  def self.up
    create_table :acts do |t|
      t.integer :activity_id
      t.string :attribute_name
      t.string :attribute_type
      t.string :string_val
      t.string :string_val_was
      t.integer :integer_val
      t.integer :integer_val_was
      t.datetime :datetime_val
      t.datetime :datetime_val_was

      t.timestamps
    end
    
    add_index :acts, :activity_id
  end

  def self.down
    drop_table :acts
  end
end
