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

  # generate the action links for a task
  def task_status_links(task)
    links = {}
         
    Task.valid_next_states(task.status).each do |stat|
      Task.valid_resolutions(stat).each do |res|
        logger.debug "Found valid state/resolution: #{stat} #{res}"
        label = label_for_status_link(stat,res)
        logger.debug "Found valid state/resolution label: #{label}"
        links[label] = url_for([task.collaboration, task]) if label
      end
    end

    links
  end
  
  def label_for_status_link(next_status, valid_resolution)
    case next_status
      when 'Assigned'
        nil # Assignment happens by changing the Assigned_To field
      when 'Accepted'
        'Accept'
      when 'Resolved'
        case valid_resolution
        when 'Completed': 'Completed'
        when 'Suspended': 'Suspend'
        end
      when 'Rejected'
        case valid_resolution
        when 'Invalid': 'Invalid!'
        when 'Duplicate': 'Duplicate!'
        when 'Not Responsible': 'Not for me!'
        end
      when 'Closed'
        'Close'
    end
  end

end
