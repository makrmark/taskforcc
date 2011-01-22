class CollaborationUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :collaboration

  has_many :tasks,
    :primary_key => 'collaboration_id',
    :foreign_key => 'collaboration_id'
  
  has_many :tasks_assigned_to,
    :class_name => 'Task',
    :primary_key => 'user_id',
    :foreign_key => 'assigned_to',
    :order => "id DESC"

  has_many :tasks_created_by,
    :class_name => 'Task',
    :foreign_key => 'created_by', 
    :order => "id DESC"
        
  # used to lookup a user by email when creating the association
  attr_accessor :email
  validates_presence_of :email, 
    :on => :create
  validates_format_of :email, 
    :on => :create, 
    :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i

  validates_presence_of :collaboration_id, :user_id, :role
  validates_inclusion_of :role, 
    :in => %w{Manager Team Observer Restricted}

  validates_uniqueness_of :user_id, :scope => :collaboration_id,
    :message => "is already in the team"

  def find_tasks_assigned_to(p)
    self.tasks_assigned_to.collaboration_filter(p[:collaboration_id]).title_filter(p[:title] || "").status_filter(p[:include_status])
  end

end
