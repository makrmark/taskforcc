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

  #
  # Menu for changing topics
  # 
  def menu_for_topics(collaboration, task)
      "<li><i class='Topics'></i>Topics ▼ #{submenu_for_topics(collaboration, task)}</li>"
  end
  def submenu_for_topics(collaboration, task)
    menu_items = ""
    collaboration.topics.each do |t|
      menu_items << "<li>#{link_for_chgtopic(task, t)}</li>" unless
        t.id == task.topic_id # can't assign to already-assigned topic
    end
    "<ul class='dir' id='tasm_topics_#{dom_id(task)}'>#{menu_items}</ul>"
  end

  #
  # Menu for changing status
  #
  def menu_for_status(task, stat)
    case stat
    when 'Assigned' # submenu is the collaboration user list
      "<li><i class='#{label_for_status(stat)}'></i>#{label_for_status(stat)} ▼ #{submenu_for_assignment(task)}</li>"
    when 'Accepted', 'Closed' # no submenu - maintain current resolution
      "<li><i class='#{label_for_status(stat)}'></i>#{link_for_chgstatus(task, stat, task.resolution, label_for_status(stat))}&nbsp;</li>"
    else # submenu is the resolution list
      "<li><i class='#{label_for_status(stat)}'></i>#{label_for_status(stat)} ▼ #{submenu_for_resolution(task, stat)} </li>"
    end
  end

  #
  # SubMenu for changing Assignment
  #
  def submenu_for_assignment(task)
    menu_items = ""
    menu_items = "<li>#{link_for_chgassign(task, @current_user.id, 'Me')}</li>"

    # TODO: this is quite a long chain - inefficient
    task.collaboration.users.each do |u|
      menu_items << "<li>#{link_for_chgassign(task, u.id, u.full_name)}</li>" unless
        u.id == task.assigned_to || # can't assign to already-assigned user
        u.id == @current_user.id    # can't assign to self (separate entry used)
    end
    "<ul class='dir' id='tasm_assigned_#{dom_id(task)}'>#{menu_items}</ul>"
  end

  #
  # SubMenu for Resolution
  #
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
      'Team'
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
        :resolution => res,
        :method => 'post' # TODO: should be put?
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
  
  def link_for_chgtopic(task, t)
    link_to_remote(t.name, 
      :url => chgstatus_collaboration_task_path({
        :collaboration_id => task.collaboration_id,
        :id => task.id,
        :topic_id => t.id
        }
      )
    )
  end


  # http://overhrd.com/?p=28
  # plain old gravatar url <%= gravatar_url_for 'greenisus@gmail.com' %>    
  # gravatar url with a rating threshold <%= gravatar_url_for 'greenisus@gmail.com', { :rating => 'R' } %>    
  # show the avatar   <%= image_tag(gravatar_url_for 'greenisus@gmail.com')%>   
  # show the avatar with size specified, in case it's served slowly  <%= image_tag(gravatar_url_for('greenisus@gmail.com'), { :width => 80, :height => 80 }) %>    
  # link the avatar to some/url  <%= link_to(image_tag(gravatar_url_for 'greenisus@gmail.com'), 'some/url')%> 
  def gravatar_url_for(email, options = {})      
    url_for({ :gravatar_id => Digest::MD5.hexdigest(email), :host => 'www.gravatar.com',                     
          :protocol => 'http://', :only_path => false, :controller => 'avatar.php'                
          }.merge(options))  
  end  

  def avatar_for(user)
    image_tag(gravatar_url_for("#{user.email}", :size=> "45", :d=> "mm"), 
      :class=> "avatar", :title => "#{user.full_name}")
  end

end
