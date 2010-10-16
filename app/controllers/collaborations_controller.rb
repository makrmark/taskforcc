class CollaborationsController < ApplicationController
  # GET /collaborations
  # GET /collaborations.xml
  def index
    @current_user = User.find(session[:user_id])
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
    @current_user = User.find(session[:user_id])
    @task = Task.new()
    @comment = Comment.new

    # when you list the tasks, set the return-to path
    session[:return_to] = request.request_uri

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @collaboration }
    end
  end

  # GET /collaborations/new
  # GET /collaborations/new.xml
  def new
    @collaboration = Collaboration.new
    @current_user = User.find(session[:user_id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collaboration }
    end
  end
  

  # GET /collaborations/1/edit
  def edit
    @collaboration = Collaboration.find(params[:id])
    @current_user = User.find(session[:user_id])
  end

  # POST /collaborations
  # POST /collaborations.xml
  def create
    @collaboration = Collaboration.new(params[:collaboration])
    @collaboration.created_by = session[:user_id]
    @current_user = User.find(session[:user_id])

    respond_to do |format|

      # TODO: use transactions here
      # http://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html
      if @collaboration.save

        # add the user to the collaboration
        @collaboration_user = CollaborationUser.new(
          :user_id => session[:user_id],
          :collaboration_id => @collaboration.id,
          :role => 'Manager',
          # TODO: this is a workaround for having email in the 
          :email => @current_user.email 
        )
        unfiled_topic = Topic.new(
          :controller => session[:user_id],
          :collaboration_id => @collaboration.id,
          :is_system => true,
          :system_name => 'unfiled',
          :name => 'Unfiled'
        )
        unfiled_topic.save
        
        logger.debug "Creating associated CollaborationUser :" + @collaboration_user.to_yaml
        if @collaboration_user.save
          logger.debug "Creating associated CollaborationUser : Success!"
          format.html { redirect_to(@collaboration, :notice => 'Collaboration was successfully created.') }
          format.xml  { render :xml => @collaboration, :status => :created, :location => @collaboration }
        else
          logger.debug "Creating associated CollaborationUser : " + @collaboration_user.errors.to_yaml
          format.html { render :action => "new" }
          format.xml  { render :xml => @collaboration_user.errors, :status => :unprocessable_entity }
        end
                
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @collaboration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /collaborations/1
  # PUT /collaborations/1.xml
  def update
    @collaboration = Collaboration.find(params[:id])

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
