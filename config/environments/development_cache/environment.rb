# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = true

# Use a different cache store in production
#config.cache_store = :mem_cache_store, '127.0.0.1' #:file_store, "#{Rails.root}/tmp/cache" # :mem_cache_store # :memory_store
config.cache_store = :file_store, 'tmp/cache'

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
# config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
config.i18n.default_locale = :de
config.i18n.locale = :de

#ts_config = ThinkingSphinx::Configuration.instance
#ts_config.raspell.dictionary             = 'de_DE'
## for available dictionaries please see:
##   ts_config.raspell.dictionaries     #=> ['en', 'en_GB', 'en_US', ... ]
#ts_config.raspell.suggestion_mode        = :normal
## for available suggestion_modes please see:
##   ts_config.raspell.suggestion_modes #=> [:ultra, :fast, :normal, :badspellers]
#ts_config.raspell.options['ignore-case'] = true