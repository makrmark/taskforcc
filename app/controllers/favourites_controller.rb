class FavouritesController < ApplicationController
  before_filter :authorize

  layout "collaborations"

  # Only Index Collaboration/User Favourite Tasks
  def index
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])
    @comment = Comment.new
  end
  
end
