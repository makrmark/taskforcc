# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # give some text a tooltip
  def titled_text(text, title)
    span = '<span class="titled-text" title="' + h(title) + '">' + h(text) + '</span>'
  end

  def breadcrumb
    span = ""
    span += "#{@collaboration.subject}" unless @collaboration.nil?
    span += " &raquo; #{@topic.name} " unless @topic.nil?
    span += " &raquo; #{@collaboration_user.user.full_name}" unless 
      @collaboration_user.nil? || @collaboration_user.user.nil?
    span += " &raquo; #{@task.title}" unless @task.nil?
    span
  end
  
  def inverse_breadcrumb(h)
    span = ""
    span += "#{h[:collaboration].subject} &raquo;" if @collaboration.nil?
    span += " #{h[:topic].name} &raquo;" if @topic.nil?
#    span += " #{h[:user].full_name}" if @collaboration_user.nil?
    span
  end
end
