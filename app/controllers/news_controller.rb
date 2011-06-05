class NewsController < ApplicationController
  before_filter :authorize
  layout "collaborations"

  def index
    default_news = session[:default_news] || 'top'
    
    if default_news.eql?('recent')
      redirect_to recent_news_path
    elsif default_news.eql?('watched')
      redirect_to watched_news_path
    else
      redirect_to top_news_path
    end
    
  end

  def recent # most recent activity
    @activities = current_user.activities.latest_filter
    @collaborations = current_user.collaborations
    @comment = Comment.new()

    session[:default_news] = 'recent'
  end

  # index only activity relating to Watched Tasks
  def watched
    favourite_task_ids = current_user.favourites.collect{ |i| i.task_id }

    @activities = current_user.activities.latest_filter.favourite_filter(favourite_task_ids)
    @collaborations = current_user.collaborations
    @comment = Comment.new()    

    session[:default_news] = 'watched'
  end
  
  def top
    @activities = current_user.top_activities.latest_filter
    @collaborations = current_user.collaborations
    @comment = Comment.new()

    session[:default_news] = 'top'
  end

end