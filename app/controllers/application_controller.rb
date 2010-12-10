# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'digest/md5'

class ApplicationController < ActionController::Base
  before_filter :authorize, :except => [:login, :signup, :dosignup, :start, :denied, :welcome]

  # TODO: check the user has access to the relevant Collaborations
  # TODO: check the user has access to the relevant Tasks (eg: Restricted users may not)
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password 
  
protected

  # TODO: move these into Helpers
  def select_user_list(collaboration)
    # to be updated once Collaborations is implemented
    users = collaboration.users
    user_list = users.map { |u| [ u.full_name + ' <' + u.email + '>', u.id] }
  end

  def select_topic_list(collaboration)
    topics = collaboration.topics
    topic_list = topics.map {|t| [ t.name, t.id ]}
  end

  def authorize
    # Don't Authorise for Pages controller
    if params[:controller].eql? "pages"
      return
    end

    # If the user is valid and logged in
    if User.find_by_id(session[:user_id])

      # Check they have access to the relevant resource
      # This is a simple check - either they're in the relevant collaboration or not!
            
      unless ( controller_name.eql?("collaborations") && params[:id].nil? ) &&
        params[:collaboration_id].nil? 

        cid = params[:collaboration_id] || params[:id]
        cu = CollaborationUser.find_by_collaboration_id_and_user_id(
          cid,
          session[:user_id]
        )
  
        if cu.nil?
          session.delete(:original_uri)
          flash[:notice] = "You do not have access to this resource"
          redirect_to url_for :controller => 'access', :action => 'denied'
          return
        end

      end

    # If not logged in, ask to log in
    else
      session[:original_uri] = request.request_uri
      flash[:notice] = "You must log in to access this resource"
      redirect_to url_for :controller => 'access', :action => 'login'
      return
    end
    
  end  

end
