class Collaboration < ActiveRecord::Base

  has_many :tasks, 
    :order => "id DESC"
  has_many :collaboration_users,
    :include => :user,
    :include => :counters
  has_many :topics, 
    :include => :counters,
    :order => "sortorder ASC, name ASC"
  has_many :users, 
    :through => :collaboration_users,   
    :order => "full_name ASC"
  has_one  :unfiled_topic, 
    :class_name => 'Topic', 
    :conditions => "system_name ='unfiled'"

  has_many :favourites
  has_many :counters

  belongs_to :user_created_by,
    :class_name => 'User',
    :primary_key => 'id',
    :foreign_key => 'created_by'

  validates_presence_of :subject, :status, :created_by

  validates_inclusion_of :status, 
    :in => %w{Open On-Hold Closed}, 
    :message => "should be Open, On-Hold, or Closed"
        
  validates_inclusion_of :is_system, 
    :in => [false], 
    :on => :update,
    :message => " cannot update system record"

  def active_users
    self.users.status_filter("Active")
  end

  # TODO: implement search on Favourites
  def favourites(uid)
    Favourite.find(:all,
      :conditions => ["collaboration_id = ? AND user_id = ?", self.id, uid],
      :order => 'created_at DESC')
  end

  def find_tasks(p, cu)
      if cu.role.eql?('Restricted')
        self.tasks.title_filter(p[:title] || "").status_filter(p[:include_status]).assigned_filter(cu.user_id)
      else
        self.tasks.title_filter(p[:title] || "").status_filter(p[:include_status])
      end
  end

private

end
