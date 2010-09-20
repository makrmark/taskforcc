class Task < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user_created_by,
    :class_name => 'User',
    :primary_key => 'id',
    :foreign_key => 'created_by'

  belongs_to :user_assigned_to,
    :class_name => 'User',
    :primary_key => 'id',
    :foreign_key => 'assigned_to'

  belongs_to :collaboration
  validates_associated :collaboration => "could not be found"  
  validates_associated :topic => "could not be found"
  
  validates_presence_of :title, :status, :resolution, :created_by, :assigned_to, :type, :collaboration_id, :topic_id

  validates_inclusion_of :status, 
    :in => %w{New Assigned Accepted On-Hold Resolved Closed}, 
    :message => " invalid"
  validate :next_state?

  validates_inclusion_of :resolution, 
    :in => %w{Unresolved Completed Duplicate Invalid}, 
    :message => " invalid"
  validate :resolution_if_resolved?

  validates_inclusion_of :type, 
    :in => %w{Task},
    :message => "should be Task"


  # valid next status given the current status
  # this becomes more complex when user roles are taken into account  
  def self.valid_next_states(status)
    case status
      when 'New'
        # Assign it for resolution or Resolve it (in case of mistake
        ['Assigned', 'Resolve']
      when 'Assigned'
        # Accept it or Reject it (or Re-Assign it)
        ['Accepted', 'Rejected']
      when 'Accepted'
        # Accept it or Reject it (or Re-Assign it)
        ['Resolved', 'Rejected', 'Assigned']
      when ['Rejected', 'Resolved']
        # Re-assign it or Close it
        ['Assigned', 'Closed']
      when 'Closed'
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
      when ['New', 'Assigned', 'Accepted']
        ['Unresolved']
      when 'Rejected'
        ['Duplicate', 'Invalid', 'Not Responsible']
      when 'Resolved'
        ['Completed', 'Suspended']
      when 'Closed'
        ['Duplicate', 'Invalid', 'Completed', 'Suspended']
      else
       ['Unresolved']
    end
  end
        
private

  #if the task is Resolved or Closed then the Resolution should be specified
  def resolution_if_resolved?
    if ( (status == "Closed" || status == "Resolved") && 
        (resolution.blank? || resolution == "Unresolved") )
        
      errors.add(:resolution, "should be specified")
      
    end
  end

  # check that the next state is valid, based on previous state  
  # for now this is really simple
  def next_state?
    if (status_changed?)
      if (status == "Closed" and status_was != "Resolved")
        errors.add(:status, "should be Resolved before Closed")
      end
    end
  end

end
