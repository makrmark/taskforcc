class TasksController < ApplicationController
  layout "collaborations"

  # GET /tasks
  # GET /tasks.xml
  def index
    @tasks = Task.all
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    @task = Task.find(params[:id])
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
    @user_list = select_user_list
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
    @user_list = select_user_list
    @current_user = User.find(session[:user_id])
    @collaboration = Collaboration.find(params[:collaboration_id])
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    @task = Task.new(params[:task])
    @task.created_by = session[:user_id]
    @current_user = User.find(session[:user_id])
    @task.collaboration_id = params[:collaboration_id]

    respond_to do |format|
      if @task.save
        format.html { redirect_to(collaboration_tasks_path(@collaboration), :notice => 'Task was successfully created.') }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
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

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
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
  
  private 

  def select_user_list
    # to be updated once Collaborations is implemented
    @users = User.find(:all)
    @user_list = @users.map { |u| [ u.full_name + ' <' + u.email + '>', u.id] }
  end
end
