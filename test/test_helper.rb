#encoding: utf-8
ENV["RAILS_ENV"] = "test"
ENV['SHOW_TEST_METHODS'] = '' if ENV['SHOW_TEST_METHODS'].nil? # 'true'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'authlogic/test_case'
require 'fileutils'

class ActiveSupport::TestCase
  include Authlogic::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # This extension prints to the log before each test.
  # Makes it easier to find the test you're looking for
  # when looking through a long test log.
  setup :clear_caches, :rebuild_search_index, :log_test, :current_fixtures_test #, 
    #:activate_authlogic
    
  teardown :clear_caches

  private
  
  def clear_caches
    expire_the_whole_cache(false)
    FileUtils.mkdir_p(ActionController::Base.cache_store.cache_path)
  end
  
  # Rebuilds the test search engine index before the first test once only.
  def rebuild_search_index(rebuild = false)
    if ((not defined?(@@search_index_rebuilded)) or rebuild == true)
      if Object.const_defined?(:ThinkingSphinx)
        config = ThinkingSphinx::Configuration.instance
        config.build
        FileUtils.mkdir_p(config.searchd_file_path)
        unless ThinkingSphinx.sphinx_running?
          # note that sphinx will be stopped after the test automatically
          config.controller.start
          if ThinkingSphinx.sphinx_running?
            #puts "Sphinx started successfully (pid #{ThinkingSphinx.sphinx_pid})."
          else
            #puts "Failed to start searchd daemon. Check #{config.searchd_log_file}"
          end
        end
        ret = config.controller.index({:verbose => false})
        #puts ret
      end
      @@search_index_rebuilded = true
    end
  end

  def log_test
    if Rails::logger
      # When I run tests in rake or autotest I see the same log message
      # multiple times per test for some reason. This guard prevents that.
      unless @already_logged_this_test
        test_class_and_method = "#{self.class}##{@method_name}"
        Rails::logger.info "\n\nStarting #{test_class_and_method}\n"+
          "#{'-' * (9 + test_class_and_method.length)}\n"
        puts "\n#{test_class_and_method}" unless ENV['SHOW_TEST_METHODS'].blank?
      end
      @already_logged_this_test = true
    end
  end

  # Test all fixture objects of the class, only if it's a real model class and
  # its table exists (than a fixtures file could exist,
  # without a fixture file there's no need to test fixture objects).
  def current_fixtures_test
    unless @already_done_current_fixtures_test
      @already_done_current_fixtures_test = true
      name = self.class.name
      if name.end_with?('Test')
        begin
          klass_name = name.gsub!('Test', '').constantize
        rescue
          return
        end
        if klass_name.respond_to?(:table_exists?) and klass_name.table_exists?
          fixture_name = klass_name.table_name + '.yml'
          if File.exist?(self.fixture_path + fixture_name)
            klass_name.find_each do |el|
              el_valid = el.valid?
              unless el_valid
                puts "Error: #{el.errors.inspect}"
                assert el_valid, 'Fixture is invalid.'
              end
            end
          end
        end
      end
    end
  end
end

module ErrorHelper
  def errors_msg(obj)
    obj.errors.full_messages.each{|m| m.to_s}.join(" \n ")
  rescue
    "Oh no! Something goes wrong with my error object!"
  end
end

require 'fileutils'
module ActiveSupport
  class TestCase
    include RewriteRoutes
    include RequestParameters
    include ActionCacheKey
    include FragmentCacheKey
    
    if Rails.version >= '3.0.0'
      include Rails.application.routes.url_helpers
    else
      include ActionController::UrlWriter
    end

    setup :set_host

    private

    def set_host
      fec = CustomConfigHandler.instance.frontend_config
      default_url_options[:host] = fec['DOMAIN']['FULL_NAME']
      default_url_options[:namespace] = nil
      default_url_options[:subdomains] = ['www']
    end
  end
end

require 'unit/helper/cache_test_helper'

module ActionController
  # Set request host, so that requested actions with in functional tests 
  # will not be redirected because of this controller mixin. 
  class TestCase
    include RewriteRoutes
    include RequestParameters
    include ActionCacheKey
    include FragmentCacheKey
    include CacheTestHelper
    
    if Rails.version >= '3.0.0'
      include Rails.application.routes.url_helpers
    else
      include ActionController::UrlWriter
    end

    setup :set_host

    private
  
    def params
      controller.params
    end
    
    if Rails.version < '3.0.0'
      def response
        @response
      end
    end

    def set_host
      fec = CustomConfigHandler.instance.frontend_config
      if @controller.is_a?(Frontend::FrontendController)
        @request.host = fec['DOMAIN']['FULL_NAME']
        default_url_options[:host] = @request.host
      elsif @controller.is_a?(Backend::BackendController)
        @request.host = fec['BACKEND']['DOMAIN']
        default_url_options[:host] = @request.host
      elsif @controller.is_a?(Mobile::MobileController)
        @request.host = "#{fec['SUBDOMAINS']['MOBILE']}.#{fec['DOMAIN']['NAME']}"
        default_url_options[:host] = @request.host
      else
        default_url_options[:host] = fec['DOMAIN']['FULL_NAME']
      end
    end
    
    def process_with_default_parameters(action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
      parameters = {:namespace => nil, :subdomains => ['www']}.merge(parameters||{})
      process_without_default_parameters(action, parameters, session, flash, http_method)
    end
    alias_method_chain :process, :default_parameters
#    # rails >= 3.1
#    module Behavior
#      def process_with_default_locale(action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
#        parameters = { :locale => I18n.default_locale }.merge( parameters || {} )
#        process_without_default_locale(action, parameters, session, flash, http_method)
#      end 
#      alias_method_chain :process, :default_locale
#    end
  
    def frontend_user_log_on(frontend_user = nil, remember_me = true)
      @current_user = frontend_user || frontend_user_for_login
      @current_user_session = FrontendUserSession.create(@current_user, remember_me)
      @current_user.last_login_at = DateTime.now
      @current_user.save
    end
    
    def frontend_user_for_login
      FrontendUser.find(:first, {:conditions => {:state => 'confirmed', :active => 1}})
    end
  end

  class IntegrationTest
    include RewriteRoutes
    include RequestParameters
    include ActionCacheKey
    include FragmentCacheKey
    include CacheTestHelper

    if Rails.version >= '3.0.0'
      include Rails.application.routes.url_helpers
    else
      include ActionController::UrlWriter
    end

    setup :set_host

    private

    def set_host
      fec = CustomConfigHandler.instance.frontend_config
      class_name = self.class.name
      if class_name.start_with?('Frontend::') or class_name.start_with?('Mobile::')
        host!(fec['DOMAIN']['FULL_NAME'])
        default_url_options[:host] = fec['DOMAIN']['FULL_NAME']
      elsif class_name.start_with?('Backend::')
        host!(fec['BACKEND']['DOMAIN'])
        default_url_options[:host] = fec['BACKEND']['DOMAIN']
      end
    end
    
    class ActionController::Integration::Session
      def url_for_with_default_parameters(options)
        options = {:namespace => nil, :subdomains => ['www']}.merge(options)
        url_for_without_default_parameters(options)
      end
      alias_method_chain :url_for, :default_parameters
    end
    
    def frontend_user_log_on
      post frontend_user_session_url, frontend_user_log_on_parameters
      assert_response :redirect
    end

    def frontend_user_log_out
      delete frontend_user_session_url
      assert_response :success
      assert_template 'frontend/user_sessions/destroy'
    end

    def frontend_user_log_on_parameters
      fu = FrontendUser.find(:first, {:conditions => {:state => 'confirmed', :active => 1}})
      return {
        :frontend_user_session => {
          :login => fu.login, 
          :password => "#{fu.first_name.downcase}s-password"
        }
      }
    end
  end

#  module Caching
#    module Pages
#      module ClassMethods
#
#        def expire_page(path)
#          return unless perform_caching
#          benchmark "Expired page: #{page_cache_file(path)}" do
#            puts "---------------------- page_cache_file(path)       : #{page_cache_file(path)}"
#            puts "---------------------- page_cache_path(path)       : #{page_cache_path(path)}"
#            puts "---------------------- page_cache_path(path) exists: #{File.exist?(page_cache_path(path))}"
#            File.delete(page_cache_path(path)) if File.exist?(page_cache_path(path))
#          end
#        end
#
#      end
#    end
#  end
end
      
# monkey-patch for ActionController::Reloader.run method,
# so it's not dependent on close being called on body,
# bypassing the BodyWrapper.
rv = Rails::VERSION
if rv::MAJOR <= 2 and rv::MINOR <= 3 and rv::TINY <= 8
  module ActionController
    class Reloader
      def self.run(lock = @@default_lock)
        lock.lock
        begin
          Dispatcher.reload_application
          status, headers, body = yield
          lock.unlock
          [status, headers, body]
        rescue Exception
          lock.unlock
          raise
        end
      end
    end
  end
end

module SubdomainRoutes
  module RoutingAssertions
    def assert_routing_with_host(path, options, host, defaults={}, extras={}, message=nil)
      if path.is_a?(String)
        path = {:path => path, :host => host}
      else
        path[:host] = host
      end
      assert_recognizes_with_host(options, path, extras, message)

      controller, default_controller = options[:controller], defaults[:controller]
      if controller && controller.include?(?/) && default_controller && default_controller.include?(?/)
        options[:controller] = "/#{controller}"
      end

      generate_options = options.dup.delete_if{ |k,v| defaults.key?(k) }
      assert_generates_with_host(path.is_a?(Hash) ? path[:path] : path, generate_options, host, defaults, extras, message)
    end
  end
end