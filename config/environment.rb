# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.15' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Load postboot file to change Rails paths
require File.join(File.dirname(__FILE__), 'postboot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{Rails.root}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  config.gem 'amount_field'
  config.gem 'authlogic'
  config.gem 'sanitize'
  config.gem 'subdomain_routes', :source => "http://gemcutter.org"
  config.gem 'thinking-sphinx', :version => '1.4.4'
  config.gem 'ya2yaml'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Berlin'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :de
  config.i18n.locale = :de

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  # create a new secret: rake secret
  config.action_controller.session = {
    :key    => "bf_#{RAILS_ENV.downcase}",
    :secret => 'ljhwagdukzxknzgyizwgdnkuyzdfwadynADYTFWIZYKUGnyKJQZ2FEFGqZmGKUZfkuzgunNUzdfwqed1d99445b14a0b3bb713f7751c56a39008fee3978b1'
  }

  #cache directory
  config.action_controller.page_cache_directory = "#{Rails.root}/public/cache"

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Default ActionMailer Configuration
  config.action_mailer.default_charset = 'utf-8'
  config.action_mailer.default_content_type = 'text/plain'
  config.action_mailer.default_mime_version = '1.0'
  config.action_mailer.default_implicit_parts_order =
    ["text/html", "text/enriched", "text/plain"]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{Rails.root}/extras )
  ##config.load_paths +=%W( #{Rails.root}/jobs ) if ENV['RAILS_JOB']
  config.autoload_paths += [
    "#{Rails.root}/lib",
    "#{Rails.root}/app/middleware",
    "#{Rails.root}/app/observer",
    "#{Rails.root}/app/sweepers",
    "#{Rails.root}/jobs/config_handler",
    
    "#{Rails.root}/app/helpers/frontend",
    "#{Rails.root}/app/helpers/backend",
    "#{Rails.root}/app/helpers/shared"
  ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  observers = []
  Dir.glob("#{Rails.root}/app/observer/*.rb").each do |file_name|
    base_name = File.basename(file_name, '.rb')
    unless base_name == 'base_observer'
      observers << base_name.to_sym
    end
  end
  config.active_record.observers = observers
  
  config.middleware.insert 0, "Frontend::Searches"
  
  config.after_initialize do
    # Enable serving of images, stylesheets, and javascripts from an asset server
    fec = CustomConfigHandler.instance.frontend_config
    config.action_controller.asset_host = "http://#{fec['DOMAIN']['FULL_NAME']}"
    
    config.action_controller.session[:session_domain] = fec['DOMAIN']['NAME']
  end
end

ActionView::Base.field_error_proc = Proc.new { |input, instance| input } 
#ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
#  "<span class='field-with-errors'>#{html_tag}</span>"
#end

#### Config Variables ##########################################################
GLOBAL_CONFIG = {
  :find_each_batch_size => 250,
  :extjs2_url_path => "/javascripts/extjs_2_3_0/",
  :extjs3_url_path => "/javascripts/extjs_3_4_0/",
  :cached_js_mobile_path  => "/js_cached/mobile/",
  :cached_js_frontend_path  => "/js_cached/frontend/",
  :cached_js_backend_path   => "/js_cached/backend/",
  :cached_css_mobile_path => "/css_cached/mobile/",
  :cached_css_frontend_path => "/css_cached/frontend/",
  :cached_css_backend_path  => "/css_cached/backend/",
  :coupon_merchant_images_cache_dir => "/coupon_merchant_images",
  :location_images_cache_dir => "/location_images"
}

#### APPLICATION_* #############################################################
$application = {}
#application name
$application[:name] = "Brunch Finden DE"
#application version
$application[:version] = "0.2"
#application stage = rails environment
$application[:stage] = Rails.env
begin
  raise unless File.exist?("#{Rails.root}/REVISION")
  File.open("#{Rails.root}/REVISION") {|f| APPLICATION_REVISION = f.readline.strip}
rescue
  if revision = IO.popen("svn info").readlines[4]
    APPLICATION_REVISION = revision.split(": ")[1].strip
  else
    APPLICATION_REVISION = 'nsi' # no svn info
  end
end
#returns app name version and svn revision as
# NAME vVERSION RREVISION
def app_version_string
  "#{$application[:name]} v#{$application[:version]} r#{APPLICATION_REVISION} (#{$application[:stage]})"
end

puts "== #{app_version_string} booted. =="

#require 'jobs/sitemap'
#ProjectSitemap.new.run
#require 'jobs/robots_txt_generator'
#RobotsTxtGenerator.new.run

# for rails 2.3.15
ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING.delete('symbol')
ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING.delete('yaml')

SubdomainRoutes::Config.domain_length = 2
