class DashboardController < ApplicationController
  before_filter :authorize
  layout "collaborations"
  
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activities }
    end
  end
  
end