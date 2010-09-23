class TasksController < ApplicationController
  layout "collaborations"
  
  # GET /tasks
  # GET /tasks.xml
  def index
    @tasks = Task.all
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])

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
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @task = Task.new
    @current_user = User.find(session[:user_id])
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
    @current_user = User.find(session[:user_id])
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
    @current_user = User.find(session[:user_id])
    @task.collaboration_id = params[:collaboration_id]
    
    @collaboration = Collaboration.find(params[:collaboration_id])
    @user_list = select_user_list(@collaboration)
    @topic_list = select_topic_list(@collaboration)

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
    @current_user = User.find(session[:user_id])
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

    @task.status     = params[:status]
    @task.resolution = params[:resolution]
#    @task.updated_by = session[:user_id]

    respond_to do |format|
      if @task.save
        format.html { redirect_to(collaboration_task_path(@task.collaboration, @task), :notice => 'Task was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
  # DELETE /tasks/1
  # DELETE /tasks/1.xml
=begin
  def destroy
    @task = Task.find(params[:id])
    @current_user = User.find(session[:user_id])
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
