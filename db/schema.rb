# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110221103746) do

  create_table "collaboration_users", :force => true do |t|
    t.integer  "collaboration_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",             :default => "Team", :null => false
  end

  add_index "collaboration_users", ["collaboration_id"], :name => "index_collaboration_users_on_collaboration_id"
  add_index "collaboration_users", ["user_id"], :name => "index_collaboration_users_on_user_id"

  create_table "collaborations", :force => true do |t|
    t.string   "subject"
    t.text     "description"
    t.string   "status"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_system",   :default => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "task_id"
    t.integer  "user_id"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["task_id"], :name => "index_comments_on_task_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "counters", :force => true do |t|
    t.integer "user_id"
    t.integer "collaboration_id"
    t.integer "topic_id"
    t.integer "cNew",             :default => 0, :null => false
    t.integer "cAssigned",        :default => 0, :null => false
    t.integer "cAccepted",        :default => 0, :null => false
    t.integer "cResolved",        :default => 0, :null => false
    t.integer "cRejected",        :default => 0, :null => false
    t.integer "cClosed",          :default => 0, :null => false
    t.integer "cTotal",           :default => 0, :null => false
  end

  add_index "counters", ["collaboration_id"], :name => "index_counters_on_collaboration_id"
  add_index "counters", ["topic_id"], :name => "index_counters_on_topic_id"
  add_index "counters", ["user_id"], :name => "index_counters_on_user_id"

  create_table "favourites", :force => true do |t|
    t.integer  "task_id"
    t.integer  "user_id"
    t.integer  "collaboration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favourites", ["collaboration_id"], :name => "index_favourites_on_collaboration_id"
  add_index "favourites", ["task_id"], :name => "index_favourites_on_task_id"
  add_index "favourites", ["user_id"], :name => "index_favourites_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "tasks", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "description"
    t.string   "task_type",        :default => "Task",       :null => false
    t.string   "status",           :default => "New",        :null => false
    t.string   "resolution",       :default => "Unresolved", :null => false
    t.integer  "created_by"
    t.integer  "assigned_to"
    t.integer  "collaboration_id"
    t.integer  "topic_id"
    t.integer  "updated_by"
  end

  add_index "tasks", ["assigned_to"], :name => "index_tasks_on_assigned_to"
  add_index "tasks", ["collaboration_id"], :name => "index_tasks_on_collaboration_id"
  add_index "tasks", ["created_at"], :name => "index_tasks_on_created_at"
  add_index "tasks", ["created_by"], :name => "index_tasks_on_created_by"
  add_index "tasks", ["status"], :name => "index_tasks_on_status"
  add_index "tasks", ["topic_id"], :name => "index_tasks_on_topic_id"
  add_index "tasks", ["updated_at"], :name => "index_tasks_on_updated_at"
  add_index "tasks", ["updated_by"], :name => "index_tasks_on_updated_by"

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.integer  "controller"
    t.integer  "collaboration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_system",        :default => false, :null => false
    t.string   "system_name"
    t.integer  "sortorder",        :default => 0,     :null => false
  end

  add_index "topics", ["collaboration_id"], :name => "index_topics_on_collaboration_id"
  add_index "topics", ["controller"], :name => "index_topics_on_controller"
  add_index "topics", ["is_system"], :name => "index_topics_on_is_system"

  create_table "users", :force => true do |t|
    t.string   "full_name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "lang"
    t.string   "time_zone"
    t.boolean  "change_pass",     :default => false
    t.string   "organisation"
    t.string   "country"
    t.string   "job_title"
    t.string   "phone_number"
    t.string   "status",          :default => "Invited", :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["full_name"], :name => "index_users_on_full_name"
  add_index "users", ["status"], :name => "index_users_on_status"

end
