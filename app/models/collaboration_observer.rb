class CollaborationObserver < ActiveRecord::Observer
  def after_create(collaboration)

    cu = CollaborationUser.new(
      :user_id => collaboration.created_by,
      :collaboration_id => collaboration.id,
      :role => 'Manager',
      :email => 'foo@bar.com' # TODO: this is ugly - fix it!
    )
    cu.save!

    unfiled_topic = Topic.new(
      :controller => collaboration.created_by,
      :collaboration_id => collaboration.id,
      :is_system => true,
      :system_name => 'unfiled',
      :name => 'Unfiled',
      :sortorder => -1000
    )
    unfiled_topic.save!

    archived_topic = Topic.new(
      :controller => collaboration.created_by,
      :collaboration_id => collaboration.id,
      :is_system => true,
      :system_name => 'archived',
      :name => 'Archived',
      :sortorder => 1000
    )
    archived_topic.save!
    
    unless collaboration.is_system
      invite_users_task = Task.new(
        :collaboration_id => collaboration.id,
        :topic_id => unfiled_topic.id,
        :created_by => collaboration.created_by,
        :updated_by => collaboration.created_by,
        :assigned_to => collaboration.created_by,
        :title => "Invite Users to Collaborate",
        :description => "Include users in your Collaboration by Inviting them to join the Team.\n\n" +
          "Users' privileges within your Collaboration depends on their Role."
      )
      invite_users_task.save!      
    end

    create_topics_task = Task.new(
      :collaboration_id => collaboration.id,
      :topic_id => unfiled_topic.id,
      :created_by => collaboration.created_by,
      :updated_by => collaboration.created_by,
      :assigned_to => collaboration.created_by,
      :title => "Create Topics",
      :description => "Create Topics to your Collaboration to organise your Tasks logically.\n\n" +
        "Each Topic may have a Mediator with additional responsibility for Tasks created in that Topic."
    )
    create_topics_task.save!

  end
end