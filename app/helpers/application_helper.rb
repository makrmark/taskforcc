# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # give some text a tooltip
  def titled_text(text, title)
    span = '<span class="titled-text" title="' + h(title) + '">' + h(text) + '</span>'
  end
  
end
