class Mobile::MobileController < ApplicationController
  include RewriteRoutes
  include RequestParameters
  include ActionCacheKey
  include FragmentCacheKey
  include ReviewTemplateFinder
  
  include Mixins::CommonFrontendMethods
  include Mixins::Authlogic
  include Mixins::MobileDeviceDetector
  include Mixins::SwitchToDesktop
  
  layout 'mobile/standard'
  
  before_filter :set_page_header_tag_configurator, :unless => lambda {|controller| controller.request.xhr?}
  before_filter :set_page_header_tags, :unless => lambda {|controller| controller.request.xhr?}
  
  #ssl_exceptions :all
  
  def self.page_cache_directory
    "#{ActionController::Base.page_cache_directory}/#{PAGE_CACHE_PATHS[:mobile]}"
  end
end