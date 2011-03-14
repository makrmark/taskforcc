class DashboardController < ApplicationController
  before_filter :authorize
  layout "collaborations"
  
  def index
    @activities = Activity.all(:order => "updated_at DESC", :limit => 10)
    @collaborations = current_user.collaborations

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activities }
    end
  end
  
end
