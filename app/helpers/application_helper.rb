# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # This can be inefficient because collaboration_user must be looked up each time.
  # and sometimes this must be determined by lookup depending on the context (eg: Comment)
  def profile_link_to(full_name, collaboration_user) 
    lnk = link_to full_name,
  		collaboration_collaboration_user_path(
  			:collaboration_id => collaboration_user.collaboration_id,
  			:id => collaboration_user.id
  			)
  	"<span class='profile_link'>#{ lnk }</span>"
  end
  
  # give some text a tooltip
  def titled_text(text, title)
    span = '<span class="titled-text" title="' + h(title) + '">' + h(text) + '</span>'
  end

  def breadcrumb
    
    span = ""
    case controller_name
    when 'collaborations'    
      span += "#{h @collaboration.subject} &raquo; " unless @collaboration.nil?
    when 'topics', 'collaboration_users', 'tasks', 'favourites'
      span += "#{h @collaboration.subject}"
      
      case controller_name
      when 'topics'
        span += " &raquo; #{h @topic.name} " unless @topic.nil?
      when 'collaboration_users'
          span += " &raquo; #{h @collaboration_user.user.full_name}" unless @collaboration_user.nil? || action_name.eql?('new')
      when 'tasks'
        span += " &raquo; #{h @task.title}" unless @task.nil?
      end      
      span += " &raquo; "
    end
    span
  end
  
  #
  # Menu for changing topics
  # 
  def menu_for_topics(collaboration, task)
    link = link_to_function(task.topic.name, 
      "toggle_tam_submenu('ttsm', '#{dom_id(task)}', 'topics')")
    "<li>#{link} <span class=\"arrow\">▼</span> #{submenu_for_topics(collaboration, task)}</li>"
  end
  
  def submenu_for_topics(collaboration, task)
    menu_items = ""
    collaboration.topics.each do |t|
      menu_items << "<li>#{link_for_chgtopic(task, t)}</li>" unless
        t.id == task.topic_id # can't assign to already-assigned topic
    end
    "<ul style=\"display: none;\" class='dir shadow' id='ttsm_topics_#{dom_id(task)}'>#{menu_items}</ul>"
  end
  
  #
  # Menu for changing status
  #
  def menu_for_status(task, stat)
    link = link_to_function(label_for_status(stat),
      "toggle_tam_submenu('trsm', '#{dom_id(task)}', '#{stat}')")
    case stat
    when 'Assigned' # submenu is the collaboration user list
      link = link_to_function('Reassign',
        "toggle_tam_submenu('tasm', '#{dom_id(task)}', 'assigned')")
       "<li><i class='Assign'></i>#{link} <span class=\"arrow\">▼</span> #{submenu_for_assignment(task)}</li>"
    when 'Accepted', 'Closed' # no submenu - maintain current resolution
      "<li><i class='#{label_for_status(stat)}'></i>#{link_for_chgstatus(task, stat, task.resolution, label_for_status(stat))}&nbsp;</li>"
    when 'Rejected', 'Resolved'
      "<li><i class='#{label_for_status(stat)}'></i>#{link_for_chgstatus(task, stat, stat, label_for_status(stat))}&nbsp;</li>"
    else # submenu is the resolution list
      "<li><i class='#{label_for_status(stat)}'></i>#{link} <span class=\"arrow\">▼</span> #{submenu_for_resolution(task, stat)} </li>"
    end
  end

  #
  # SubMenu for changing Assignment
  #
  def submenu_for_assignment(task)
    menu_items = ""
    menu_items = "<li>#{link_for_chgassign(task, @current_user.id, 'Myself')}</li>"

    # TODO: this is quite a long chain - inefficient
    task.collaboration.users.status_filter("Active").each do |u|
      menu_items << "<li>#{link_for_chgassign(task, u.id, u.full_name)}</li>" unless
        u.id == task.assigned_to || # can't assign to already-assigned user
        u.id == @current_user.id    # can't assign to self (separate entry used)
    end
    "<ul style=\"display: none;\" class='dir shadow' id='tasm_assigned_#{dom_id(task)}'>#{menu_items}</ul>"
  end

  #
  # SubMenu for Resolution
  #
  def submenu_for_resolution(task, stat)
    menu_items = ""
    
    Task.valid_resolutions(stat).each do |res|
      menu_items << "<li>#{link_for_chgstatus(task, stat, res, res)}</li>"
    end    
    "<ul style=\"display: none;\" class='dir shadow' id='trsm_#{stat}_#{dom_id(task)}'>#{menu_items}</ul>"
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
      ),
      :loading => "Element.show('resultset-spinner-container')",
      :complete => "Element.hide('resultset-spinner-container')"
    )
  end

  # TODO: Assign to self sets status as 'Accepted'
  def link_for_chgassign(task, uid, label)
    link_to_remote(h(label), 
      :url => chgstatus_collaboration_task_path({
        :collaboration_id => task.collaboration_id,
        :id => task.id,
        :status => 'Assigned',
        :resolution => 'Unresolved',
        :assigned_to => uid
        }
      ),
      :loading => "Element.show('resultset-spinner-container')",
      :complete => "Element.hide('resultset-spinner-container')"
    )
  end  
  
  def link_for_chgtopic(task, t)
    link_to_remote(h(t.name), 
      :url => chgstatus_collaboration_task_path({
        :collaboration_id => task.collaboration_id,
        :id => task.id,
        :topic_id => t.id
        }
      ),
      :loading => "Element.show('resultset-spinner-container')",
      :complete => "Element.hide('resultset-spinner-container')"
    )
  end

  def link_for_chgtype(task, task_type)
    link_to_remote(%Q{<i class="tt #{task_type}" title="#{task_type}"></i>}, 
      :url => chgstatus_collaboration_task_path({
        :collaboration_id => task.collaboration_id,
        :id => task.id,
        :task_type => task_type
        }
      ),
      :loading => "Element.show('resultset-spinner-container')",
      :complete => "Element.hide('resultset-spinner-container')"
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
  
  def mini_avatar_for(user)
    image_tag(gravatar_url_for("#{user.email}", :size=> "45", :d=> "mm"), 
      :class=> "avatar mini", :title => "#{user.full_name}")
  end

  def med_avatar_for(user)
    image_tag(gravatar_url_for("#{user.email}", :size=> "45", :d=> "mm"), 
      :class=> "avatar medium", :title => "#{user.full_name}")
  end


end
