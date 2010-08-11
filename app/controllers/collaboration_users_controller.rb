class CollaborationUsersController < ApplicationController

  # GET /collaboration_users
  # GET /collaboration_users.xml
  def index
    @collaboration_users = CollaborationUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @collaboration_users }
    end
  end

  # GET /collaboration_users/list/1
  # GET /collaboration_users/list/1.xml
  def list
    @collaboration = Collaboration.find(params[:collaboration_id])
    @collaboration_users = CollaborationUser.find_all_by_collaboration_id(params[:collaboration_id])

    respond_to do |format|
      format.html # list.html.erb
      format.xml  { render :xml => @collaboration_users }
    end
  end

  # GET /collaboration_users/1
  # GET /collaboration_users/1.xml
  def show
    @collaboration_user = CollaborationUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @collaboration_user }
    end
  end

  # GET /collaboration_users/new
  # GET /collaboration_users/new.xml
  def new
    @collaboration_user = CollaborationUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collaboration_user }
    end
  end

  # GET /collaboration_users/1/edit
  def edit
    @collaboration_user = CollaborationUser.find(params[:id])
  end

  # POST /collaboration_users
  # POST /collaboration_users.xml
  def create
    @collaboration_user = CollaborationUser.new(params[:collaboration_user])

    respond_to do |format|
      if @collaboration_user.save
        format.html { redirect_to(@collaboration_user, :notice => 'CollaborationUser was successfully created.') }
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

    respond_to do |format|
      if @collaboration_user.update_attributes(params[:collaboration_user])
        format.html { redirect_to(@collaboration_user, :notice => 'CollaborationUser was successfully updated.') }
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

    respond_to do |format|
      format.html { redirect_to(collaboration_users_url) }
      format.xml  { head :ok }
    end
  end
end
