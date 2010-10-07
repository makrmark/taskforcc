class FavouritesController < ApplicationController
  layout "collaborations"

#
# Only 
# - Index Collaboration/User Favourite Tasks
# - Create Collaboration/User Favourite Task
# - Delete Collaboration/User Favourite Task
#
# Supply a View only for Index since Create/Delete will occur in one step
  
  def index
    @favourites = Favourite.all
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @favourites }
    end
  end

  def create
    @favourite = Favourite.new(params[:favourite])
    @favourite.user_id = session[:user_id]

    #TODO: or does this come from params?
    @favourite.collaboration_id = params[:collaboration_id] 
    
    @collaboration = Collaboration.find(params[:collaboration_id])
    @user_list = select_user_list(@collaboration)
    @topic_list = select_topic_list(@collaboration)

    respond_to do |format|
      if @favourite.save
        format.html { redirect_to(request.referrer, :notice => 'Favourite was successfully created.') }
        format.xml  { render :xml => @favourite, :status => :created, :location => @favourite }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @favourite.errors, :status => :unprocessable_entity }
      end
    end
  end
  
begin
  def destroy
    @favourite = Favourite.find(params[:id])
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])
    @favourite.destroy

    respond_to do |format|
      format.html { redirect_to( redirect_to(request.referrer, :notice => 'Favourite was successfully created.') }
      format.xml  { head :ok }
    end
  end

end
