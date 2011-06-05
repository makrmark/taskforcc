class NewsController < ApplicationController
  before_filter :authorize
  layout "collaborations"

  def recent # most recent activity
    @activities = current_user.activities.latest_filter
    @collaborations = current_user.collaborations
    @comment = Comment.new()
  end

  # index only activity relating to Watched Tasks
  def watched
    favourite_task_ids = current_user.favourites.collect{ |i| i.task_id }

    @activities = current_user.activities.latest_filter.favourite_filter(favourite_task_ids)
    @collaborations = current_user.collaborations
    @comment = Comment.new()    
  end
  
  def top
    @activities = current_user.top_activities.latest_filter
    @collaborations = current_user.collaborations
    @comment = Comment.new()
  end

end