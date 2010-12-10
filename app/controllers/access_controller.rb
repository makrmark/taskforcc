class AccessController < ApplicationController
# TODO: maybe move to Restful Authentication:
# http://railsonedge.blogspot.com/2008/03/rails-forum-restful-authenticationpart.html

  def start
    @user = User.new()
  end

  def login
    if request.post?
      @user = User.authenticate(params[:email], params[:password])
      if @user        
          session[:user_id] = @user.id

          # this is normally only set for first login
          # TODO: maybe it's better to user "reg-step" - less ambiguous
          if @user.change_pass?
            redirect_to chgpass_user_path(@user) 
          else # normally this path is used
            uri = session[:original_uri]
            session[:original_uri] = nil
            redirect_to( uri || url_for(:controller => 'collaborations') )
          end
      else
        flash.now[:notice] = "Invalid email/password combination"
      end
    else
      @user = User.new()
    end  
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "You have been logged out"
    redirect_to root_path
  end

  def signup
    # first sign the user out if they are already signed in
    session[:user_id] = nil if session[:user_id]

    # then create the new user object
    @user = User.new

    respond_to do |format|
      format.html
    end
  end

  def dosignup

    if request.post?
      @user = User.new(params[:user])
      @user.password = User.random_password
      @user.change_pass = true

      respond_to do |format|
        if @user.save
          # session[:user_id] = @user.id
          # uri = session[:original_uri]
          # session[:original_uri] = nil
          
          @user.send_welcome
  
          flash[:notice] = "You will receive a confirmation email including your login credentials."
          format.html { redirect_to( url_for :action => 'login' ) }
        else
          # TODO: How can you differentiate between a Commit error and a Validation error.
          flash[:error] = "Errors occurred during signup."
          format.html { render :action => "signup" }
        end          
      end
    end    
  end
    
  def welcome
  end
  
  def denied
  end

end
