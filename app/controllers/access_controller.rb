class AccessController < ApplicationController
  def login
    if request.post?
      user = User.authenticate(params[:email], params[:password])
      if user
          session[:user_id] = user.id
          uri = session[:original_uri]
          session[:original_uri] = nil
          redirect_to( uri || url_for(:controller => 'collaborations') )
      else
        flash.now[:notice] = "Invalid email/password combination"
      end
    end  
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "You have been logged out"
    redirect_to(:action => 'login')
  end

  # Originally copied from UsersController
  def signup
    # first sign the user out if they are already signed in
    session[:user_id] = nil if session[:user_id]

    # then create the new user object
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def dosignup
    if request.post?
      @user = User.new(params[:user])
  
      respond_to do |format|
        if @user.save
          session[:user_id] = @user.id
          uri = session[:original_uri]
          session[:original_uri] = nil
          AccountMailer.deliver_welcome(@user)

          format.html { redirect_to( uri || url_for(:controller => 'collaborations') ) }
        else
          format.html { render :action => "signup" }
        end
      end
    end
  end
  
  def welcome
  end

end
