# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

# Use a different cache store in production
# config.cache_store = :mem_cache_store
# ActionController::Base.cache_store = :mem_cache_store, "127.0.0.1","192.168.50.11"
#config.cache_store = :mem_cache_store, '127.0.0.1'
config.cache_store = :file_store, 'tmp/cache/test'

# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
# config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
config.i18n.default_locale = :en
config.i18n.locale = :en

config.after_initialize do
#  ts_config = ThinkingSphinx::Configuration.instance
#  ts_config.raspell.dictionary             = 'en'
#  # for available dictionaries please see:
#  #   ts_config.raspell.dictionaries     #=> ['en', 'en_GB', 'en_US', ... ]
#  ts_config.raspell.suggestion_mode        = :normal
#  # for available suggestion_modes please see:
#  #   ts_config.raspell.suggestion_modes #=> [:ultra, :fast, :normal, :badspellers]
#  ts_config.raspell.options['ignore-case'] = true
end

#cache directory
config.action_controller.page_cache_directory = "#{Rails.root}/public/cache/test"
