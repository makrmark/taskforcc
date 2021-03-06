class Task < ActiveRecord::Base
  belongs_to :topic
  belongs_to :collaboration

  # See: CollaborationUserTask model class
  belongs_to :collaboration_user_task,
    :primary_key => 'collaboration_id',
    :foreign_key => 'collaboration_id'

  # Task -> CollaborationUsers(collaboration_id) -> Users 
  has_many :users, 
    :through => :collaboration_users
    
  has_many :favourites
  has_many :favourite_users,
    :class_name => 'Favourite',
    :include => :user
  
  has_many :comments,
    :order => 'created_at ASC'
  
  belongs_to :user_created_by,
    :class_name => 'User',
    :primary_key => 'id',
    :foreign_key => 'created_by'

  belongs_to :user_updated_by,
    :class_name => 'User',
    :primary_key => 'id',
    :foreign_key => 'updated_by'

  belongs_to :user_assigned_to,
    :class_name => 'User',
    :primary_key => 'id',
    :foreign_key => 'assigned_to'  
    
  has_many :activities,
    :order => 'updated_at ASC',
    :include => :acts
  
  has_one :latest_activity,
    :class_name => 'Activity',
    :conditions => {:is_latest => true}
  
  # http://railscasts.com/episodes/108-named-scope
  # http://refactormycode.com/codes/788-advanced-search-form-named-scopes
  # http://apidock.com/rails/ActiveRecord/NamedScope/ClassMethods/named_scope
  # BUG: Search should be case-insensitive - create an index on lcase(title)?
  named_scope :title_filter, lambda { |t| 
    words = t.split(/ /)
    expr  = words.map {|f| "title like ?"}
    vals  = words.map {|f| "%#{f}%"}
    
    { :conditions => [expr.join(" AND ")] + vals }
  }
  named_scope :collaboration_filter, lambda { |t| 
    { :conditions => { :collaboration_id => t } } 
  }
  named_scope :status_filter, lambda { |t| 
    { :conditions => { :status => Task.include_status_from_filter(t) } }
  }
  named_scope :assigned_filter, lambda { |t|
    { :conditions => { :assigned_to => t }}    
  }
      
  validates_presence_of :title, :task_type, :status, :resolution, 
    :created_by, :updated_by, :assigned_to, 
    :collaboration_id, :topic_id
    
  validates_length_of :title, :maximum => 150
  
  validate :valid_state_transition?
  validate :valid_state_for_role?
  validate :valid_resolution?

  validates_inclusion_of :task_type, 
    :in => %w{Task Risk Issue Question Defect Idea}

  def can_create?(user)
    valid_states_by_user(user).include?('New')
  end
    
  # Return the states possible by the current user and for current task status
  # TODO: review acts_as_state_machine
  # http://agilewebdevelopment.com/plugins/acts_as_state_machine
  def valid_states_by_user(user)
    
    was_assigned = user.id == assigned_to
    
    vsbcs = Task.valid_next_states(status)
    vsbcr = Task.valid_states_by_collaboration_role(collaboration_role(user.id), was_assigned)
    vsbtr = Task.valid_states_by_topic_role(is_topic_controller(user.id))

    vsbu = vsbcs & (vsbcr | vsbtr)
  end

  # valid next status given the current status
  def self.valid_next_states(status)
    case status
    when 'New' then
      # Assign it for resolution or Resolve/Reject it (in case of mistake)
      ['Resolved', 'Rejected', 'Assigned']
    when 'Assigned' then
      # Accept it or Reject it (or Re-Assign it)
      ['Accepted', 'Rejected', 'Assigned']
    when 'Accepted' then
      # Accept it or Reject it (or Re-Assign it)
      ['Resolved', 'Rejected', 'Assigned']
    when 'Rejected', 'Resolved' then
      # Re-assign it or Close it
      ['Closed', 'Assigned']
    when 'Closed' then
      # Re-Open and Assign it
      ['Assigned']
    else
      # when no previous status
      ['New', 'Assigned']
    end
  end
  
  # valid resolutions according to the given status
  def self.valid_resolutions(stat)
    case stat
    when 'Resolved' then
      ['Resolved']
    when 'Rejected' then
      ['Rejected']
    when 'Closed' then
      ['Rejected', 'Resolved']
    else
      ['Unresolved']
    end
  end
  
  def self.valid_states_by_collaboration_role(role, was_assigned)
    case role
    when 'Manager' then # Can do anything, anytime
      ['New', 'Assigned', 'Accepted', 'Rejected', 'Resolved', 'Closed']
    when 'Team' then # Only can't Close
      if was_assigned
        ['New', 'Assigned', 'Accepted', 'Rejected', 'Resolved']
      else
        ['Assigned']
      end
    when 'Restricted' then # Re-assign, Accept, or Reject
      if was_assigned
        ['New', 'Assigned', 'Accepted', 'Rejected', 'Resolved']
      else
        []
      end
    else # Others can't do anything
      []
    end    
  end
  
  def self.valid_states_by_topic_role(is_controller)
    if is_controller # only controller can Close
      ['Closed']
    else
      []
    end
  end

  def self.include_status_from_filter(fltr)
    logger.debug("Including from Status Filter: #{fltr}")
    case fltr
    when 'All Open Tasks' then
      ['New', 'Assigned', 'Accepted', 'Rejected', 'Resolved']
    when 'All Tasks' then
      ['New', 'Assigned', 'Accepted', 'Rejected', 'Resolved', 'Closed']
    when 'New', 'Assigned', 'Accepted', 'Rejected', 'Resolved', 'Closed' then
      fltr
    else
      ['New', 'Assigned', 'Accepted', 'Rejected', 'Resolved']
    end
    
  end


  def self.auditable_attribute?(attribute_name)
    ['title', 'type', 'status', 'resolution', 'topic_id', 'assigned_to'].include?(attribute_name)    
  end
  
  def self.auditable_attribute_type(attribute_name)
    type_map = {
      'title' => 'string',
      'type'  => 'string',
      'status' => 'string',
      'resolution' => 'string',
      'topic_id' => 'integer-string',
      'assigned_to' => 'integer-string'
    }
    
    return type_map[attribute_name]

  end
  
  def auditable_attribute_string_val(attribute_name, integer_val)
    case attribute_name
    when 'topic_id'
      topic = Topic.find(integer_val)
      topic.name
    when 'assigned_to'
      user = User.find(integer_val)
      user.full_name
    end
  end

private

  #if the task is Resolved or Closed then the Resolution should be specified
  def valid_resolution?
    if !Task.valid_resolutions(status).include?(resolution)
      errors.add(:resolution, "invalid")
    end
  end

  # check that the next state is valid, based on previous state and user roles
  def valid_state_transition?
    if status_changed?
      if !Task.valid_next_states(status_was).include?(status)
        errors.add(:status, "invalid transition")
      end
    end    
  end

  # a single validation since the roles can intersect
  def valid_state_for_role?

    was_assigned = updated_by == assigned_to
    
    vsbcr = Task.valid_states_by_collaboration_role(collaboration_role(updated_by), was_assigned)
    vsbtr = Task.valid_states_by_topic_role(is_topic_controller(updated_by))

    vsbr = vsbtr | vsbcr

    if ! vsbr.include?(status)
      errors.add(:status, "invalid for role")
    end
  end

  def is_topic_controller(uid)
    unless self.topic.nil? 
      self.topic.controller == uid
    end
  end

  def collaboration_role(uid)
    cu = CollaborationUser.find(:first, 
      :conditions => ["collaboration_id = ? AND user_id = ?", collaboration_id, uid])

    role = cu.role unless cu.nil?
  end
  
end
