# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'digest/md5'

class ApplicationController < ActionController::Base

  # TODO: check the user has access to the relevant Collaborations
  # TODO: check the user has access to the relevant Tasks (eg: Restricted users may not)
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password 
  
  helper_method :current_user
  
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

    # If the user is valid and logged in
    if current_user

      # Check they have access to the relevant resource
      # This is a simple check - either they're in the relevant collaboration or not!
      if ['collaborations','activities', 'dashboard'].include?(controller_name) && 
        params[:id].nil?

        # impossible to ascertain if user has access if collaboration_id not specified

      elsif ['topics', 'collaboration_users', 'favourites'].include?(controller_name) && 
        params[:collaboration_id].nil?
        
        # impossible to ascertain if user has access if collaboration_id not specified

      elsif controller_name.eql?('users') && params.has_key?(:id)

        # don't let users view each other's profiles directly
        unless params[:id].to_s == session[:user_id].to_s          
          session.delete(:original_uri)
          flash[:notice] = "You do not have access to this resource"
          redirect_to url_for :controller => 'access', :action => 'denied'
          return
        end

      else
        cid = controller_name.eql?("collaborations") ? params[:id] : params[:collaboration_id]
        cu = CollaborationUser.find_by_collaboration_id_and_user_id(
          cid,
          session[:user_id]
        )

        # if the user does not exist in the collaboration then deny access
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
  
  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

end
