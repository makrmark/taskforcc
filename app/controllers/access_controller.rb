class AccessController < ApplicationController

# TODO: maybe move to Restful Authentication:
# http://railsonedge.blogspot.com/2008/03/rails-forum-restful-authenticationpart.html

  def start
    if current_user
      redirect_to collaborations_path
    end

    @user = User.new()
  end

  def login
    if request.post?
      @user = User.authenticate(params[:email], params[:password])

      # user was authenticated
      if @user
          session[:user_id] = @user.id

          # Activate the user account on first login
          if @user.status.eql?("Invited")
            flash[:notice]  = "Welcome to Taskforcc! Your account is now Active."
            @user.status = "Active"
            @user.skip_password_check = true
            @user.save!
          end

          # The user should change their pass, 
          # either on first login or after requesting a password reset
          if @user.change_pass?
            flash[:notice] = flash[:notice] ? "#{flash[:notice]}<br>" : ""
            flash[:notice] += "Please change your temporary password to something more secure."
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
    redirect_to url_for(:controller => :access, :action => :login)
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

  def recover
    if request.post?
      @user = User.find_by_email(params[:email])

      # the user could not be found
      if @user.nil?

        flash[:error] = "Email address not found"
        
        respond_to do |format|
          format.html { render :action => "recover" }
        end

      # user found - reset their password
      else
        @user.password = User.random_password
        @user.change_pass = true
        @user.save!
        @user.send_recover
        flash[:notice] = "Login using your new password sent to you by email"
        redirect_to url_for(:controller => :access, :action => :login)
      end      
    end    
  end
    
  def denied
  end

end
