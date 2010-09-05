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
    :in => %w{New Assigned On-Hold Resolved Closed}, 
    :message => "should be New, Assigned, On-Hold, Resolved, or Closed"
  validate :next_state?

  validates_inclusion_of :resolution, 
    :in => %w{Unresolved Completed Duplicate Invalid}, 
    :message => "should be Unresolved, Completed, Duplicate, or Invalid"
  validate :resolution_if_resolved?

  validates_inclusion_of :type, 
    :in => %w{Task},
    :message => "should be Task"
        
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
