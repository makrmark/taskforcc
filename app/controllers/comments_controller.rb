class CommentsController < ApplicationController
  before_filter :authorize

  layout "collaborations"
  
end
