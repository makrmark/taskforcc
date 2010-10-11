class Task < ActiveRecord::Base
  belongs_to :topic
  has_many :favourites
  has_many :comments
  
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
    
  belongs_to :collaboration
  validates_associated :collaboration => "could not be found"  
  validates_associated :topic => "could not be found"
  
  validates_presence_of :title, :type, :status, :resolution, 
    :created_by, :updated_by, :assigned_to, 
    :collaboration_id, :topic_id

  validate :valid_state_transition?
  validate :valid_state_for_role?
  validate :valid_resolution?

  validates_inclusion_of :type, 
    :in => %w{Task},
    :message => "should be Task"

  # Return the states possible by the current user and for current task status
  def valid_states_by_user(uid)
    vsbcs = Task.valid_next_states(status)
    vsbcr = Task.valid_states_by_collaboration_role(collaboration_role(uid))
    vsbtr = Task.valid_states_by_topic_role(is_topic_controller(uid))

    vsbu = vsbcs & (vsbcr | vsbtr)
  end

  # valid next status given the current status
  def self.valid_next_states(status)
    case status
    when 'New' then
      # Assign it for resolution or Resolve it (in case of mistake)
      ['Resolved', 'Assigned']
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
      ['Completed', 'Suspended']
    when 'Rejected' then
      ['Duplicate', 'Invalid', 'Not Responsible']
    when 'Closed' then
      ['Duplicate', 'Invalid', 'Completed', 'Suspended']
    else
      ['Unresolved']
    end
  end
  
  def self.valid_states_by_collaboration_role(role)
    case role
    when 'Manager' then # Can do anything
      ['New', 'Assigned', 'Accepted', 'Rejected', 'Resolved', 'Closed']
    when 'Team' then # Only can't Close
      ['New', 'Assigned', 'Accepted', 'Rejected', 'Resolved']
    when 'Restricted' then # Re-assign, Accept, or Reject
      ['New', 'Assigned', 'Accepted', 'Rejected', 'Resolved']
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
    
    vsbcr = Task.valid_states_by_collaboration_role(collaboration_role(updated_by))
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
