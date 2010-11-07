class UsersController < ApplicationController
  layout "collaborations"

  # GET /users
  # GET /users.xml
  def index
    @users = User.all
    @current_user = User.find(session[:user_id])
    @collaborations = @current_user.collaborations

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    @current_user = User.find(session[:user_id])
    @collaborations = @current_user.collaborations

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    @current_user = User.find(session[:user_id])
    @collaborations = @current_user.collaborations

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    @current_user = User.find(session[:user_id])
    @collaborations = @current_user.collaborations
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    @current_user = User.find(session[:user_id])
    @collaborations = @current_user.collaborations

    respond_to do |format|
      if @user.save
        format.html { redirect_to(@user, :notice => 'User was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    @current_user = User.find(session[:user_id])
    
    @user.skip_password_check = true

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # screen to change your password
  # GET
  def chgpass
    @user = User.find(params[:id])
    @current_user = User.find(session[:user_id])
    
  end

  # action to update your password  
  # PUT
  def setpass
    @current_user = User.find(session[:user_id])
    @user = User.find(params[:id])
    @user.change_pass = false

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'Password was successfully updated.') }
      else
        format.html { render :action => "chgpass" }
      end
    end
  end


end
