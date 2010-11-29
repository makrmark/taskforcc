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

  end
end