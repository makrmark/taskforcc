class ActivitiesController < ApplicationController
  before_filter :authorize
  layout "collaborations"

  def index
    @activities = current_user.activities.latest_filter
    @collaborations = current_user.collaborations
    @comment = Comment.new()

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activities }
    end
  end

  # index only activity relating to Watched Tasks
  def watched
    
    favourite_task_ids = current_user.favourites.collect{ |i| i.task_id }
    @activities = current_user.activities.latest_filter.favourite_filter(favourite_task_ids)
    @collaborations = current_user.collaborations
    @comment = Comment.new()

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activities }
    end
    
  end

end