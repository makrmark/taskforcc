class Collaboration < ActiveRecord::Base
  after_create :setup_collaboration

  has_many :tasks, :order => "id DESC"
  has_many :collaboration_users
  has_many :topics, :order => "system_name DESC, name ASC"
  has_many :users, :through => :collaboration_users, :order => "full_name ASC"
  has_one  :unfiled_topic, 
    :class_name => 'Topic', 
    :conditions => "system_name ='unfiled'"
  has_many :favourites

  belongs_to :user_created_by,
    :class_name => 'User',
    :primary_key => 'id',
    :foreign_key => 'created_by'

  validates_presence_of :subject, :status, :created_by

  validates_inclusion_of :status, 
    :in => %w{Open On-Hold Closed}, 
    :message => "should be Open, On-Hold, or Closed"

  def favourites(uid)
    Favourite.find(:all,
      :conditions => ["collaboration_id = ? AND user_id = ?", self.id, uid],
      :order => 'created_at DESC')
  end
  
private

  # Add the user to the collaboration as a Manager
  # And setup the default 'Unfiled' topic with the user as Controller
  def setup_collaboration
    
    logger.debug "In setup_collaboration"
    
    cu = CollaborationUser.new(
      :user_id => self.created_by,
      :collaboration_id => self.id,
      :role => 'Manager',
      :email => 'foo@bar.com' # TODO: this is ugly - fix it!
    )
    logger.debug cu.errors.to_yaml unless cu.save 

    unfiled_topic = Topic.new(
      :controller => self.created_by,
      :collaboration_id => self.id,
      :is_system => true,
      :system_name => 'unfiled',
      :name => 'Unfiled'
    )
    unfiled_topic.save    
    
  end

end
