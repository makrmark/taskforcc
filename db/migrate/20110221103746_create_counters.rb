class CreateCounters < ActiveRecord::Migration
  def self.up
    create_table :counters do |t|
      t.integer :user_id
      t.integer :collaboration_id
      t.integer :topic_id
      t.integer :cNew,      :null => false, :default => 0
      t.integer :cAssigned, :null => false, :default => 0
      t.integer :cAccepted, :null => false, :default => 0
      t.integer :cResolved, :null => false, :default => 0
      t.integer :cRejected, :null => false, :default => 0
      t.integer :cClosed,   :null => false, :default => 0
      t.integer :cTotal,    :null => false, :default => 0

    end

    execute "INSERT INTO counters (user_id, collaboration_id, topic_id, " +
        "cNew, cAssigned, cAccepted, cResolved, cRejected, cClosed, cTotal) " +
      "SELECT assigned_to, collaboration_id, topic_id, " +
      "SUM ( CASE WHEN status='New'       THEN 1 ELSE 0 END ) as cNew, " +
      "SUM ( CASE WHEN status='Assigned'  THEN 1 ELSE 0 END ) as cAssigned, " +
      "SUM ( CASE WHEN status='Accepted'  THEN 1 ELSE 0 END ) as cAccepted, " +
      "SUM ( CASE WHEN status='Resolved'  THEN 1 ELSE 0 END ) as cResolved, " +
      "SUM ( CASE WHEN status='Rejected'  THEN 1 ELSE 0 END ) as cRejected, " +
      "SUM ( CASE WHEN status='Closed'    THEN 1 ELSE 0 END ) as cClosed, " +
      "COUNT(*) as cTotal " +
      "FROM tasks "+
      "GROUP BY assigned_to, collaboration_id, topic_id;"

    add_index :counters, :user_id
    add_index :counters, :collaboration_id
    add_index :counters, :topic_id
  end

  def self.down
    drop_table :counters
  end
end
