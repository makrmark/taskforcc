class TopicsController < ApplicationController
  before_filter :authorize

  layout "collaborations"

=begin
  def add_task    
    @collaboration = Collaboration.find(params[:collaboration_id])
    @topic = Topic.find(params[:id])
    @current_user = current_user

    @task = Task.find(params[:task_id])
    @task.topic_id = @topic.id

    respond_to do |format|
      if @task.save
         format.js
       end
    end    
  end
=end

  # GET /topics
  # GET /topics.xml
  def index
    @current_user = current_user
    @collaboration = Collaboration.find(params[:collaboration_id])
    @topics = @collaboration.topics

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @topics }
    end
  end

  # GET /topics/1
  # GET /topics/1.xml
  def show
    @topic = Topic.find(params[:id])
    @current_user = current_user
    @collaboration = Collaboration.find(params[:collaboration_id])
    @collaboration_user = CollaborationUser.find_by_user_id_and_collaboration_id(
      @current_user.id, @collaboration.id)

    @task = Task.new(
      :created_by => @current_user.id, 
      :assigned_to => @current_user.id, 
      :collaboration_id => @collaboration.id,
      :topic_id => @topic.id
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
      format.xml  { render :xml => @topic }
    end
  end

  # GET /topics/new
  # GET /topics/new.xml
  def new
    @topic = Topic.new
    @current_user = current_user
    @collaboration = Collaboration.find(params[:collaboration_id])
    @user_list = select_user_list(@collaboration)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # GET /topics/1/edit
  def edit
    @topic = Topic.find(params[:id])
    @current_user = current_user
    @collaboration = Collaboration.find(params[:collaboration_id])
    @user_list = select_user_list(@collaboration)

  end

  # POST /topics
  # POST /topics.xml
  def create
    @topic = Topic.new(params[:topic])
    @current_user = current_user
    @collaboration = Collaboration.find(params[:collaboration_id])
    @user_list = select_user_list(@collaboration)

    @topic.collaboration_id = @collaboration.id

    respond_to do |format|
      if @topic.save
        format.html { redirect_to(collaboration_topics_path(@collaboration), :notice => 'Topic was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /topics/1
  # PUT /topics/1.xml
  def update
    @topic = Topic.find(params[:id])
    @current_user = current_user
    @collaboration = Collaboration.find(params[:collaboration_id])
    @user_list = select_user_list(@collaboration)

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        format.html { redirect_to(collaboration_topics_path(@collaboration), :notice => 'Topic was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

end
