class CollaborationsController < ApplicationController
  before_filter :authorize

# TODO: Not needed yet  
#  in_place_edit_for :collaboration, :description

  # in_place_edit_for :collaboration, :subject
  # http://railsforum.com/viewtopic.php?id=1624
#  def set_collaboration_subject
#      @collaboration = Collaboration.find(params[:id])
#      @collaboration.update_attributes(:subject => params[:value])
#      render :text => @collaboration.reload.subject # reload so it returns the old name if it wasn't saved
#  end
  
  def list
    @current_user = current_user
    @collaborations = @current_user.collaborations

    # when you list the tasks, set the return-to path
    session[:return_to] = request.request_uri

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @collaborations }
    end

  end
  
  # GET /collaborations
  # GET /collaborations.xml
  def index
    @current_user = current_user
    @collaborations = @current_user.collaborations
    @comment = Comment.new

    # when you list the tasks, set the return-to path
    session[:return_to] = request.request_uri

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @collaborations }
    end
  end

  # GET /collaborations/1
  # GET /collaborations/1.xml
  def show
    @collaboration = Collaboration.find(params[:id])
    @current_user = current_user
    @collaboration_user = CollaborationUser.find_by_user_id_and_collaboration_id(
      @current_user.id, @collaboration.id)

    @task = Task.new(
      :created_by => @current_user.id, 
      :assigned_to => @current_user.id, 
      :collaboration_id => @collaboration.id,
      :topic_id => @collaboration.unfiled_topic.id
    )
    @comment = Comment.new

    # when you list the tasks, set the return-to path
    session[:return_to] = request.request_uri

    if params[:commit].eql?("Search Here")
      session[:active_tab] = "search"
      logger.debug("Active tab set to search")
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @collaboration }
    end
  end

  # GET /collaborations/new
  # GET /collaborations/new.xml
  def new
    @collaboration = Collaboration.new
    @current_user = current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collaboration }
    end
  end
  

  # GET /collaborations/1/edit
  def edit
    @collaboration = Collaboration.find(params[:id])
    @current_user = current_user
  end

  # POST /collaborations
  # POST /collaborations.xml
  def create
    @collaboration = Collaboration.new(params[:collaboration])
    @collaboration.created_by = session[:user_id]
    @current_user = current_user

    respond_to do |format|

      # TODO: use transactions here
      # http://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html
      if @collaboration.save
          format.html { redirect_to(collaboration_news_index_path @collaboration, :notice => 'Collaboration was successfully created.') }
          format.xml  { render :xml => @collaboration, :status => :created, :location => @collaboration }
      else
        flash[:error] = "Errors creating taskforcc."
        format.html { render :action => "new" }
        format.xml  { render :xml => @collaboration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /collaborations/1
  # PUT /collaborations/1.xml
  def update
    @collaboration = Collaboration.find(params[:id])
    @current_user = current_user

    respond_to do |format|
      if @collaboration.update_attributes(params[:collaboration])
        format.html { redirect_to(@collaboration, :notice => 'Collaboration was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @collaboration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /collaborations/1
  # DELETE /collaborations/1.xml
=begin
  def destroy
    @collaboration = Collaboration.find(params[:id])
    @collaboration.destroy

    respond_to do |format|
      format.html { redirect_to(collaborations_url) }
      format.xml  { head :ok }
    end
  end
=end
end
