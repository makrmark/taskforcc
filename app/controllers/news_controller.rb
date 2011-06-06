class NewsController < ApplicationController
  before_filter :authorize, :setup
  layout "collaborations"

  def setup
    # remember where to go back to
    session[:return_to_index] = request.request_uri

    if params[:collaboration_id]
      @collaboration = Collaboration.find(params[:collaboration_id])
    end
    if params[:topic_id]
      @topic = Topic.find(params[:topic_id])
      @collaboration = Collaboration.find(params[:collaboration_id])
    end
    if params[:collaboration_user_id]
      @collaboration_user = CollaborationUser.find(params[:collaboration_user_id])
      @collaboration = Collaboration.find(params[:collaboration_id])
    end
    
    @collaborations = current_user.collaborations
    @comment = Comment.new()
  end

  def index
    news_view = session[:news_view] || 'top'
    
    if news_view.eql?('recent')
      recent
    elsif news_view.eql?('watched')
      watched
    else
      top
    end

    respond_to do |format|
        format.html { render :action => news_view }
    end    
  end

  # TODO: do we really need to jump through all these hoops with the filters?
  def recent # most recent activity    

    if @topic
      @activities = current_user.activities.latest_filter.topic_filter(@topic.id)      
    elsif @collaboration_user
      @activities = current_user.activities.latest_filter.collaboration_filter(@collaboration_id).user_filter(@collaboration_user.user_id)            
    elsif @collaboration
      @activities = current_user.activities.latest_filter.collaboration_filter(@collaboration.id)
    else
      @activities = current_user.activities.latest_filter      
    end
    session[:news_view] = 'recent'
  end

  # index only activity relating to Watched Tasks
  def watched
    favourite_task_ids = current_user.favourites.collect{ |i| i.task_id }
    
    if @collaboration
      if session[:news_view].eql?('top')
        @activities = current_user.top_activities.latest_filter.favourite_filter(favourite_task_ids).collaboration_filter(@collaboration.id)
      else
        @activities = current_user.activities.latest_filter.favourite_filter(favourite_task_ids).collaboration_filter(@collaboration.id)
      end
    else
      if session[:news_view].eql?('top')
        @activities = current_user.top_activities.latest_filter.favourite_filter(favourite_task_ids)
      else
        @activities = current_user.activities.latest_filter.favourite_filter(favourite_task_ids)
      end
    end
  end
  
  def top
    if @topic
      @activities = current_user.top_activities.latest_filter.topic_filter(@topic.id)      
    elsif @collaboration_user
      @activities = current_user.top_activities.latest_filter.collaboration_filter(@collaboration_id).user_filter(@collaboration_user.user_id)            
    elsif @collaboration
      @activities = current_user.top_activities.latest_filter.collaboration_filter(@collaboration.id)
    else
      @activities = current_user.top_activities.latest_filter
    end
    session[:news_view] = 'top'
  end

end