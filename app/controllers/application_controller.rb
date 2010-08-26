# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :authorize, :except => [:login, :signup, :dosignup]
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password 
  
protected

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
    unless User.find_by_id(session[:user_id])
      session[:original_uri] = request.request_uri
      flash[:notice] = "Please log in"
      redirect_to :controller => 'access', :action=> 'login'
    end
  end
end
