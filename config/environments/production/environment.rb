# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

## Enable serving of images, stylesheets, and javascripts from an asset server
## config.action_controller.asset_host                  = "http://assets.example.com"
## Fileserver (v6fs1):
#ActionController::Base.asset_host = Proc.new do |source|
#  unless source =~/\/backend\//
#    if source =~ /_images\//
#      ["media0.brunch-finden.de","media1.brunch-finden.de"][source.length.modulo(2)] 
#    elsif source =~ /(_cached|images)\//
#      "static.brunch-finden.de"
#    end
#  end
#end

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store
# ActionController::Base.cache_store = :mem_cache_store, "127.0.0.1","192.168.50.11"
#config.cache_store = :mem_cache_store, '127.0.0.1'
config.cache_store = :file_store, 'tmp/cache'

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
#config.threadsafe!

# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
# config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
config.i18n.default_locale = :de
config.i18n.locale = :de

#ts_config = ThinkingSphinx::Configuration.instance
#ts_config.raspell.dictionary             = 'de_DE'
# for available dictionaries please see:
#   ts_config.raspell.dictionaries     #=> ['en', 'en_GB', 'en_US', ... ]
#ts_config.raspell.suggestion_mode        = :normal
# for available suggestion_modes please see:
#   ts_config.raspell.suggestion_modes #=> [:ultra, :fast, :normal, :badspellers]
#ts_config.raspell.options['ignore-case'] = true
