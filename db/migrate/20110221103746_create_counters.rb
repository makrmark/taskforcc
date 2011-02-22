class CreateCounters < ActiveRecord::Migration
  def self.up
    create_table :counters do |t|
      t.integer :user_id
      t.integer :collaboration_id
      t.integer :topic_id
      t.integer :cnt_new,      :null => false, :default => 0
      t.integer :cnt_assigned, :null => false, :default => 0
      t.integer :cnt_accepted, :null => false, :default => 0
      t.integer :cnt_resolved, :null => false, :default => 0
      t.integer :cnt_rejected, :null => false, :default => 0
      t.integer :cnt_closed,   :null => false, :default => 0
      t.integer :cnt_total,    :null => false, :default => 0

    end

    execute "INSERT INTO counters (user_id, collaboration_id, topic_id, " +
        "cnt_new, cnt_assigned, cnt_accepted, cnt_resolved, cnt_rejected, cnt_closed, cTotal) " +
      "SELECT assigned_to, collaboration_id, topic_id, " +
      "SUM ( CASE WHEN status='New'       THEN 1 ELSE 0 END ) as cnt_new, " +
      "SUM ( CASE WHEN status='Assigned'  THEN 1 ELSE 0 END ) as cnt_assigned, " +
      "SUM ( CASE WHEN status='Accepted'  THEN 1 ELSE 0 END ) as cnt_accepted, " +
      "SUM ( CASE WHEN status='Resolved'  THEN 1 ELSE 0 END ) as cnt_resolved, " +
      "SUM ( CASE WHEN status='Rejected'  THEN 1 ELSE 0 END ) as cnt_rejected, " +
      "SUM ( CASE WHEN status='Closed'    THEN 1 ELSE 0 END ) as cnt_closed, " +
      "COUNT(*) as cnt_total " +
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
