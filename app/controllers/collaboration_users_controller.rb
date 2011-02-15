class CollaborationUsersController < ApplicationController
  before_filter :authorize

  layout "collaborations"
  
  # GET /collaboration_users
  # GET /collaboration_users.xml
  def index
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])

    @collaboration_users = @collaboration.collaboration_users
    # CollaborationUser.find_all_by_collaboration_id(params[:collaboration_id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @collaboration_users }
    end
  end

  # GET /collaboration_users/1
  # GET /collaboration_users/1.xml
  def show
    @collaboration_user = CollaborationUser.find(params[:id])
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])

    @task = Task.new(
      :created_by => @current_user.id, 
      :assigned_to => @collaboration_user.user_id, 
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
      format.xml  { render :xml => @collaboration_user }
    end
  end

  # GET /collaboration_users/new
  # GET /collaboration_users/new.xml
  def new
    @collaboration_user = CollaborationUser.new
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collaboration_user }
    end
  end

  # GET /collaboration_users/1/edit
  def edit
    @collaboration_user = CollaborationUser.find(params[:id])
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])
  end

  # POST /collaboration_users
  # POST /collaboration_users.xml
  def create
    @collaboration_user = CollaborationUser.new(params[:collaboration_user])
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])

    # TODO: could enforce this in the model
    @collaboration_user.collaboration_id = @collaboration.id

    # see if there is an existing user to add
    # TODO: Otherwise ask the user to confirm whether to invite them to join    
    # TODO: use transactions here
    logger.debug "Searching for " + @collaboration_user.email

    user_to_add = User.find_by_email(@collaboration_user.email)
    if user_to_add.nil? then
      logger.debug "NO matching user found for " + @collaboration_user.email
      logger.debug "Creating a new one... "
      
      user_to_add = User.invite(@collaboration_user.email, @current_user)
      
    else
      logger.debug "Matching user found for " + @collaboration_user.email + " : " + user_to_add.to_yaml
    end
    @collaboration_user.user_id = user_to_add.id

    respond_to do |format|
      if @collaboration_user.save

        # send the invite email
        AccountMailer.deliver_invite_to_collaborate(user_to_add, @current_user, @collaboration)
        
        format.html { redirect_to(collaboration_collaboration_users_path(@collaboration), 
            :notice => 'Invitation Sent!') }
        format.xml  { render :xml => @collaboration_user, :status => :created, :location => @collaboration_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @collaboration_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /collaboration_users/1
  # PUT /collaboration_users/1.xml
  def update
    @collaboration_user = CollaborationUser.find(params[:id])
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])

    respond_to do |format|
      if @collaboration_user.update_attributes(params[:collaboration_user])
        format.html { redirect_to(collaboration_collaboration_user_path(
          :collaboration_id => @collaboration_user.collaboration_id,
          :id => @collaboration_user.id), 
          :notice => 'Collaboration User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @collaboration_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /collaboration_users/1
  # DELETE /collaboration_users/1.xml
  def destroy
    @collaboration_user = CollaborationUser.find(params[:id])
    @collaboration_user.destroy
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])

    respond_to do |format|
      format.html { redirect_to(collaboration_collaboration_users_path(@collaboration)) }
      format.xml  { head :ok }
    end
  end
end
