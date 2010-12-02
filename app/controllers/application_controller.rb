# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'digest/md5'

class ApplicationController < ActionController::Base
  before_filter :authorize, :except => [:login, :signup, :dosignup, :start]

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
    if params[:controller].eql? "pages"
      return
    end
    unless User.find_by_id(session[:user_id])
      session[:original_uri] = request.request_uri
      flash[:notice] = "You must log in to access this resource"
      redirect_to url_for :controller => 'access', :action => 'login'
    end
  end  

end
