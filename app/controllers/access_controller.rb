class AccessController < ApplicationController
  def login
    if request.post?
      user = User.authenticate(params[:email], params[:password])
      if user
          session[:user_id] = user.id
          uri = session[:original_uri]
          session[:original_uri] = nil
          redirect_to( uri || {:action => "welcome"} )
      else
        flash.now(:notice, "Invalid email/password combination")    
      end
    end  
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "You have been logged out"
    redirect_to(:action => 'login')
  end
  
  def welcome
  end

end
