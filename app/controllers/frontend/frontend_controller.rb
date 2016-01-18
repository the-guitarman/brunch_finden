class Frontend::FrontendController < ApplicationController
  include RewriteRoutes
  include RequestParameters
  include ActionCacheKey
  include FragmentCacheKey
  include ReviewTemplateFinder
  
  include Mixins::CommonFrontendMethods
  include Mixins::Authlogic
  include Mixins::MobileDeviceDetector
  include Mixins::SwitchToMobile
  
  layout 'frontend/standard'
  
  before_filter :set_page_header_tag_configurator, :unless => lambda {|controller| controller.request.xhr?}
  before_filter :set_page_header_tags, :unless => lambda {|controller| controller.request.xhr?}
  
  #ssl_exceptions :all
  
  def self.page_cache_directory
    "#{ActionController::Base.page_cache_directory}/#{PAGE_CACHE_PATHS[:frontend]}"
  end
  
  private
  
  alias original_load_globals load_globals
  def load_globals
    original_load_globals
    
    image_path = "#{root_url}/images/logo_de_simple.png".gsub('//', '/')
    
    @facebook_tags = {
      'fb:admins'       => '100002169140350',
      'fb:page_id'      => nil,
      'fb:app_id'       => nil,
      'og:image'        => image_path,
      'og:url'          => root_url,
      'og:country-name' => 'Germany',
      'og:locality'     => 'Chemnitz',
      'og:latitude'     => nil, # float value: 48.78502
      'og:longitude'    => nil, # float value: 1.78502
      'og:type'         => 'website', # cafe, restaurant
      'og:site_name'    => @host_full_name,
      'og:title'        => nil,
      'og:description'  => nil
    }
    
    @twitter_tags = {
      'twitter:card'        => 'summary',
      'twitter:url'         => root_url,
      'twitter:title'       => @host_full_name,
      'twitter:description' => nil,
      'twitter:image'       => image_path
    }
    
    @schema_org_tags = {
      'name'        => @host_full_name,
      'description' => nil,
      'image'       => image_path
    }
  end
  
  alias original_set_page_header set_page_header_tags
  def set_page_header_tags
    original_set_page_header
    
    if @page_header_tags and @facebook_tags
      unless @page_header_tags['title'].blank?
        @facebook_tags['og:title'] = @page_header_tags['title'] 
        @twitter_tags['twitter:title'] = @page_header_tags['title']
        @schema_org_tags['name'] = @page_header_tags['title']
      end
      unless @page_header_tags['meta']['description'].blank?
        @facebook_tags['og:description'] = @page_header_tags['meta']['description']
        @twitter_tags['twitter:description'] = @page_header_tags['meta']['description']
        @schema_org_tags['description'] = @page_header_tags['meta']['description']
      end
    end
  end
end