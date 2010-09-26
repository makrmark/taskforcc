require 'test_helper'

class TaskTest < ActiveSupport::TestCase

  def setup
    @user1 = User.new(:full_name => 'User 1', 
      :email => 'User1@mail.com', :email_confirmation => 'User1@mail.com',
      :password => 'mypass', :password_confirmation => 'mypass')
    @user1.save
    @user2 = User.new(:full_name => 'User 2', 
      :email => 'User2@mail.com', :email_confirmation => 'User2@mail.com',
      :password => 'mypass', :password_confirmation => 'mypass')
    @user2.save
    @user3 = User.new(:full_name => 'User 3', 
      :email => 'User3@mail.com', :email_confirmation => 'User3@mail.com',
      :password => 'mypass', :password_confirmation => 'mypass')
    @user3.save
    @user4 = User.new(:full_name => 'User 4', 
      :email => 'User4@mail.com', :email_confirmation => 'User4@mail.com',
      :password => 'mypass', :password_confirmation => 'mypass')
    @user4.save
    @user5 = User.new(:full_name => 'User 5', 
      :email => 'User5@mail.com', :email_confirmation => 'User5@mail.com',
      :password => 'mypass', :password_confirmation => 'mypass')
    @user5.save
    
    @collaboration1 = Collaboration.new(:subject => 'Collaboration1', 
      :status => 'Open', :created_by => @user1.id)   
    @collaboration1.save
    @collaboration2 = Collaboration.new(:subject => 'Collaboration2', 
      :status => 'Open', :created_by => @user2.id)
    @collaboration2.save

    @topic11 = Topic.new(:name => 'Topic1_1', :controller => @user1.id, 
      :collaboration_id => @collaboration1.id)
    @topic11.save
    @topic12 = Topic.new(:name => 'Topic1_2', :controller => @user2.id, 
      :collaboration_id => @collaboration1.id)
    @topic12.save
    @topic21 = Topic.new(:name => 'Topic2_1', :controller => @user1.id, 
      :collaboration_id => @collaboration2.id)
    @topic21.save
    @topic22 = Topic.new(:name => 'Topic2_2', :controller => @user2.id, 
      :collaboration_id => @collaboration2.id)
    @topic22.save

    @collaboration_user11 = CollaborationUser.new(:user_id => @user1.id, 
      :collaboration_id => @collaboration1.id, :role => 'Manager', :email => @user1.email)
    @collaboration_user11.save
    @collaboration_user12 = CollaborationUser.new(:user_id => @user2.id, 
      :collaboration_id => @collaboration1.id, :role => 'Team', :email => @user2.email)
    @collaboration_user12.save

    @collaboration_user21 = CollaborationUser.new(:user_id => @user1.id, 
      :collaboration_id => @collaboration2.id, :role => 'Manager', :email => @user1.email)
    @collaboration_user21.save
    @collaboration_user22 = CollaborationUser.new(:user_id => @user2.id, 
      :collaboration_id => @collaboration2.id, :role => 'Team', :email => @user2.email)
    @collaboration_user22.save
    @collaboration_user23 = CollaborationUser.new(:user_id => @user3.id, 
      :collaboration_id => @collaboration2.id, :role => 'Restricted', :email => @user3.email)
    @collaboration_user23.save
    @collaboration_user24 = CollaborationUser.new(:user_id => @user4.id, 
      :collaboration_id => @collaboration2.id, :role => 'Observer', :email => @user4.email)
    @collaboration_user24.save
    # Note: User 5 doesn't belong in any Collaborations at all
    
  end

#
# Truthiness tests
#
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test "Invalid with Empty Attributes" do
    task = Task.new()
    assert !task.valid?
    assert task.errors.invalid?(:title)
    assert task.errors.invalid?(:created_by)
    assert task.errors.invalid?(:updated_by)
    assert task.errors.invalid?(:assigned_to)
    assert task.errors.invalid?(:topic_id)
    assert task.errors.invalid?(:collaboration_id)
    assert task.errors.invalid?(:status)
    assert !task.errors.invalid?(:type)
    assert !task.errors.invalid?(:resolution)    
  end

#
# Tests of Valid State Transitions and Resolutions
#
  test "Resolve and Close" do

    task = Task.new()
    task.title = "Resolve and Close"
    task.created_by = @user1.id
    task.updated_by = @user1.id
    task.assigned_to = @user1.id #note: the topic controller
    task.collaboration_id = @collaboration1.id
    task.topic_id = @topic11.id
    assert task.valid?
    assert task.save
    
    # assign the task
    task.status = "Assigned"
    assert task.valid?
    assert task.save
    
    # can't go back to New
    task.status = "New"
    assert !task.valid?

    # accept the task    
    task.status = "Accepted"
    assert task.valid?
    assert task.save

    # resolve the task    
    task.status = "Resolved"
    assert !task.valid?
    assert !task.errors.invalid?(:status)
    assert task.errors.invalid?(:resolution) # because we haven't set the resolution

    # set a valid resolution for Resolved    
    task.resolution = "Completed"
    assert task.valid?
    assert !task.errors.invalid?(:status)
    assert !task.errors.invalid?(:resolution)
    assert task.save
    
    # close the task - success
    task.status = "Closed"
    assert task.valid?
    assert !task.errors.invalid?(:status)
    assert !task.errors.invalid?(:resolution)    
    assert task.save        
  end
  
  test "Reject and Re-Assign" do
    task = Task.new()
    task.title = "Reject and Re-Assign"
    task.created_by = @user1.id
    task.updated_by = @user1.id
    task.assigned_to = @user1.id
    task.collaboration_id = @collaboration1.id
    task.topic_id = @topic11.id

    assert task.valid?    
    assert task.save    
    
    # assign the task
    task.status = "Assigned"
    assert task.valid?
    assert task.save
    
    # can't go back to New
    task.status = "New"
    assert !task.valid?

    # accept the task    
    task.status = "Rejected"
    assert !task.valid?
    assert !task.errors.invalid?(:status)
    assert task.errors.invalid?(:resolution) # because we haven't set the resolution

    task.resolution = "Resolved"
    assert !task.valid?
    assert !task.errors.invalid?(:status)
    assert task.errors.invalid?(:resolution) # invalid resolution 'Unresolved'

    task.resolution = "Not Responsible"
    assert task.valid?
    assert task.save
    
    task.status = "Closed"
    assert !task.valid?
    assert !task.errors.invalid?(:status)
    assert task.errors.invalid?(:resolution) # Can't close with Not Responsible

    task.status = "Assigned"
    assert !task.valid?
    assert !task.errors.invalid?(:status)
    assert task.errors.invalid?(:resolution) # should be Unresolved

    task.resolution = "Unresolved"
    assert task.valid?
    assert task.save

  end  

#
# Check assignment within collaboration_users
# ie: you can't assign to someone not in collaboration_users
#

# Confirm Restricted can only work with Tasks assigned to them

#
# Check Collaboration roles can perform correct actions
# eg: 
# . Observers can't do anything (except view/watch/comment)
# . Manager can Close (even when not Topic Controller)
  test "Valid Actions for Collaboration Roles" do
    task = Task.new()
    task.title = "Valid Actions for Collaboration Roles"
    task.created_by = @user1.id
    task.assigned_to = @user2.id #note: not the topic controller
    task.collaboration_id = @collaboration2.id
    task.topic_id = @topic21.id

    # Task status = New
    task.updated_by = @user5.id # doesn't exist in this collaboration
    assert !task.save
    task.updated_by = @user4.id # Observer can't create
    assert !task.save
    task.updated_by = @user3.id # Restricted can create
    assert task.save
    task.updated_by = @user2.id # Team can create
    assert task.save
    task.updated_by = @user1.id # Manager can create
    assert task.save

    task.status = "Assigned"    
    task.updated_by = @user5.id # doesn't exist in this collaboration
    assert !task.save
    task.updated_by = @user4.id # Observer can't assign
    assert !task.save
    task.updated_by = @user3.id # Restricted can assign
    assert task.save
    task.updated_by = @user2.id # Team can assign
    assert task.save
    task.updated_by = @user1.id # Manager can assign
    assert task.save

    task.status = "Accepted"    
    task.updated_by = @user5.id # doesn't exist in this collaboration
    assert !task.save
    # TODO: Can't assign to Observer!
    task.updated_by = @user4.id # Observer can't accept 
    assert !task.save
    task.updated_by = @user3.id # Restricted can accept
    assert task.save
    task.updated_by = @user2.id # Team can accept
    assert task.save
    task.updated_by = @user1.id # Manager can accept
    assert task.save
    
    task.status = "Resolved"    
    task.resolution = "Completed"    
    task.updated_by = @user5.id # doesn't exist in this collaboration
    assert !task.save
    task.updated_by = @user4.id # Observer can't resolve
    assert !task.save
    task.updated_by = @user3.id # Restricted can resolve
    assert task.save
    task.updated_by = @user2.id # Team can resolve
    assert task.save
    task.updated_by = @user1.id # Manager can resolve
    assert task.save

    task.status = "Closed"    
    task.updated_by = @user5.id # doesn't exist in this collaboration
    assert !task.save
    task.updated_by = @user4.id # Observer can't close
    assert !task.save
    task.updated_by = @user3.id # Restricted can't close
    assert !task.save
    task.updated_by = @user2.id # Team can't close (when not Topic Controller)
    assert !task.save
    task.updated_by = @user1.id # Manager can close
    assert task.save

    task.status = "Assigned"
    task.resolution = "Unresolved"
    task.updated_by = @user5.id # doesn't exist in this collaboration
    assert !task.save
    task.updated_by = @user4.id # Observer can't reopen
    assert !task.save
    task.updated_by = @user3.id # Restricted can reopen
    assert task.save
    task.updated_by = @user2.id # Team can reopen
    assert task.save
    task.updated_by = @user1.id # Manager can reopen
    assert task.save

    task.status = "Rejected"
    task.resolution = "Invalid"
    task.updated_by = @user5.id # doesn't exist in this collaboration
    assert !task.save
    task.updated_by = @user4.id # Observer can't reject
    assert !task.save
    task.updated_by = @user3.id # Restricted can reject
    assert task.save
    task.updated_by = @user2.id # Team can reject
    assert task.save
    task.updated_by = @user1.id # Manager can reject
    assert task.save

  end

#
# Check Topic roles can perform correct actions
# eg:
# . Only Topic Controller can close
  test "Only Topic Controller Can Close" do
    task = Task.new()
    task.title = "Only Topic Controller Can Close"
    task.created_by = @user1.id
    task.updated_by = @user1.id
    task.assigned_to = @user2.id #note: not the topic controller
    task.collaboration_id = @collaboration1.id
    task.topic_id = @topic11.id
    assert task.save
    
    # straight away resolve it
    task.status = "Resolved"
    task.resolution = "Completed"
    assert task.save
    
    # close the task - failure
    task.status = "Closed"
    task.updated_by = @user2.id # user IS NOT the topic controller
    assert !task.valid?
    assert task.errors.invalid?(:status)
    assert !task.errors.invalid?(:resolution)    
    assert !task.save

    # close the task - success
    task.status = "Closed"
    task.updated_by = @user1.id # user IS the topic controller
    assert task.valid?
    assert !task.errors.invalid?(:status)
    assert !task.errors.invalid?(:resolution)    
    assert task.save        
  end

end
