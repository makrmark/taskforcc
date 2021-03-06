class TasksController < ApplicationController
  before_filter :authorize

  layout "collaborations"

# TODO: this is not necessary right now  
  in_place_edit_for :task, :description

  # in_place_edit_for :task, :title
  # http://railsforum.com/viewtopic.php?id=1624
  def set_task_title
      @task = Task.find(params[:id])
      @task.update_attributes(:title => params[:value])
      render :text => @task.reload.title # reload so it returns the old name if it wasn't saved
  end

  # Add a comment to a Task
  def comment
    @task = Task.find(params[:id])
    @current_user = current_user

    @comment = Comment.new(params[:comment])
    @comment.user_id = session[:user_id]
    @comment.task_id = params[:id]

    respond_to do |format|
      if @comment.save
        format.html { redirect_to(request.referrer, :notice => 'Your comment was added successfully.') }
        format.xml  { head :ok }
        format.js
      end
    end
  end

  # Favourite or UnFavourite a Task
  def favourite
    @task = Task.find(params[:id])
#    @current_user = current_user

    # refactor into Task model
    favourite = Favourite.find(:first, 
      :conditions => ["task_id = ? AND user_id = ?", params[:id], session[:user_id]])

    # TODO: does the current user have access to this collaboration?
    # can we do this using filters?

    # does the favourite already exist?
    # if yes, destroy it
    if favourite
      favourite.destroy
    # if no, create it
    else
      favourite = Favourite.new()
      favourite.user_id = session[:user_id]
      favourite.collaboration_id = params[:collaboration_id]
      favourite.task_id = params[:id]
      favourite.save
    end    

    respond_to do |format|
      format.html { redirect_to(request.referrer, :notice => 'Task was successfully favourited.') }
      format.xml  { head :ok }
      format.js
    end
  end
    
  # GET /tasks
  # GET /tasks.xml
  def index
    @tasks = Task.all
    @current_user = current_user
    @collaboration = Collaboration.find(params[:collaboration_id])
    @comment = Comment.new

    # when you list the tasks, set the return-to path
    session[:return_to] = request.request_uri

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    @task = Task.find(params[:id])
    @topic = @task.topic;
    @current_user = current_user
    @collaboration = Collaboration.find(params[:collaboration_id])
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.erb
      format.js
    end
  end

  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @task = Task.new
    @current_user = current_user
    @collaboration = Collaboration.find(params[:collaboration_id])
    @user_list = select_user_list(@collaboration)
    @topic_list = select_topic_list(@collaboration)
    
    @task.topic_id    = params[:topic_id] if params[:topic_id]
    @task.assigned_to = params[:assigned_to] if params[:assigned_to]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @current_user = current_user
    @task = Task.find(params[:id])
    @topic = @task.topic;
    @collaboration = Collaboration.find(params[:collaboration_id])
    @user_list = select_user_list(@collaboration)
    @topic_list = select_topic_list(@collaboration)
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    @task = Task.new(params[:task])
    @task.created_by = session[:user_id]
    @task.updated_by = session[:user_id]
    @current_user = current_user
    @task.collaboration_id = params[:collaboration_id]
        
    @collaboration = Collaboration.find(params[:collaboration_id])
    @user_list = select_user_list(@collaboration)
    @topic_list = select_topic_list(@collaboration)    
    @comment = Comment.new()

    if params[:commit].eql?("Task Here")
      session[:active_tab] = "taskhere" 
      logger.debug("Active tab set to taskhere")
    end

    respond_to do |format|
      if @task.save
        format.html { redirect_to(request.referrer, :notice => 'Task was successfully created.') }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    @task = Task.find(params[:id])
    @current_user = current_user
    @task.updated_by = session[:user_id]
    @collaboration = Collaboration.find(params[:collaboration_id])
    @user_list = select_user_list(@collaboration)
    @topic_list = select_topic_list(@collaboration)

    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html { redirect_to(collaboration_tasks_path(@collaboration), :notice => 'Task was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def chgstatus
    @task = Task.find(params[:id])

    @task.topic_id   = params[:topic_id]    if params[:topic_id]
    @task.status     = params[:status]      if params[:status]
    @task.task_type  = params[:task_type]   if params[:task_type]
    @task.resolution = params[:resolution]  if params[:resolution]
    @task.assigned_to= params[:assigned_to] if params[:assigned_to]
    @task.updated_by = session[:user_id]

    @current_user = current_user
    @collaboration = Collaboration.find(params[:collaboration_id])
    @comment = Comment.new()

    respond_to do |format|
      if @task.save!
        format.html { redirect_to(request.referrer, :notice => 'Task was successfully updated.') }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
        format.js
      end
    end
    
  end
  
  # DELETE /tasks/1
  # DELETE /tasks/1.xml
=begin
  def destroy
    @task = Task.find(params[:id])
    @current_user = current_user
    @collaboration = Collaboration.find(params[:collaboration_id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to( collaboration_tasks_url(
        :collaboration_id => @collaboration.id
      ) ) }
      format.xml  { head :ok }
    end
  end
=end

end
