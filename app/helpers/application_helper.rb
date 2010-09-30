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

  def menu_for_status(task, stat)
    case stat
    when 'Assigned' # submenu is the collaboration user list
      "<li>#{label_for_status(stat)}+ #{submenu_for_assignment(task)}</li>"
    when 'Accepted', 'Closed' # no submenu - maintain current resolution
      "<li>#{link_for_chgstatus(task, stat, task.resolution, label_for_status(stat))}</li>"
    else # submenu is the resolution list
      "<li>#{label_for_status(stat)}+ #{submenu_for_resolution(task, stat)}</li>"
    end
  end

=begin
  # for the submenu toggling
  # http://www.devarticles.com/c/a/Ruby-on-Rails/Introducing-scriptaculous/2/
  def toggle_link_for_assignment(task, stat)
    label = label_for_status(stat)
    link_to_function label,
        "new Effect.toggle('tasm_assigned_#{dom_id(task)}')"    
  end

  def toggle_link_for_resolution(task, stat)
    label = label_for_status(stat)
    link_to_function label,
        "new Effect.toggle('trsm_#{stat}_#{dom_id(task)}')"
  end
=end

  def submenu_for_assignment(task)
    menu_items = ""
    menu_items = "<li>#{link_for_chgassign(task, @current_user.id, 'Me')}</li>" unless
        task.assigned_to == @current_user.id # already assigned to self

    @collaboration.users.each do |u|
      menu_items << "<li>#{link_for_chgassign(task, u.id, u.full_name)}</li>" unless
        u.id == task.assigned_to || # can't assign to already-assigned user
        u.id == @current_user.id    # can't assign to self (separate entry used)
    end
    "<ul class='dir' id='tasm_assigned_#{dom_id(task)}'>#{menu_items}</ul>"
  end

  def submenu_for_resolution(task, stat)
    menu_items = ""
    
    Task.valid_resolutions(stat).each do |res|
      logger.debug "Found valid state/resolution: #{stat} #{res}"
      menu_items << "<li>#{link_for_chgstatus(task, stat, res, res)}</li>"
    end    
    "<ul class='dir' id='trsm_#{stat}_#{dom_id(task)}'>#{menu_items}</ul>"
  end

  def label_for_status(stat)
    case stat
    when 'Assigned'
      'Assign'
    when 'Accepted'
      'Accept'
    when 'Resolved'
      'Resolve'
    when 'Rejected'
      'Reject'
    when 'Closed'
      'Close'
    end
  end
  
  def link_for_chgstatus(task, stat, res, label)
    link_to_remote(label, 
      :url => chgstatus_collaboration_task_path({
        :collaboration_id => task.collaboration_id,
        :id => task.id,
        :status => stat,
        :resolution => res
        }
      )
    )
  end

  # TODO: Assign to self sets status as 'Accepted'
  def link_for_chgassign(task, uid, label)
    link_to_remote(label, 
      :url => chgstatus_collaboration_task_path({
        :collaboration_id => task.collaboration_id,
        :id => task.id,
        :status => 'Assigned',
        :resolution => 'Unresolved',
        :assigned_to => uid
        }
      )
    )
  end  
end
