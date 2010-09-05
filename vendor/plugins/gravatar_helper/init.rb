require 'gravatar_helper'
require_dependency 'application_helper'

ActionView::Base.send :include, GravatarHelper
