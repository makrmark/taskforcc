class Topic < ActiveRecord::Base
  belongs_to :collaboration
  belongs_to :user, :foreign_key => :controller
  has_many :tasks, :order => "id DESC"
  has_many :favourites

  validates_presence_of :name, :controller, :collaboration_id

  def find_tasks(p)
      self.tasks.title_filter(p[:title] || "").status_filter(p[:include_status])
  end
  
end
