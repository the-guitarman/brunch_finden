module Mixins::CacheSweeper
  # Hook: The class/model, which includes this module,
  # calls this module method, if it will be included to the class/model.
  def self.included(klass)
    klass.instance_eval do
      extend ClassMethods
      include InstanceMethods

      # UrlWriter used to create rewrite paths
      if Rails.version >= '3.0.0'
        unless klass.included_modules.include?(Rails.application.routes.url_helpers)
          include Rails.application.routes.url_helpers
        end
      else
        unless klass.included_modules.include?(ActionController::UrlWriter)
          include ActionController::UrlWriter
        end
      end
      
      unless klass.included_modules.include?(RewriteRoutes)
        include RewriteRoutes
      end

      before_save   :before_save_cache_sweeper_handler

      after_create  :after_create_cache_sweeper_handler
      after_update  :after_update_cache_sweeper_handler
      after_destroy :after_destroy_cache_sweeper_handler
    end
  end

  # define all class methods in this module
  # (e.g. Category.my_class_method)
  module ClassMethods
    def acts_as_cache_sweeper(options_hash = {})
      cattr_accessor :expire_pages
      cattr_accessor :expire_page_for_parent_objects
      
      self.expire_pages = options_hash.delete(:expire_pages) || []
      self.expire_page_for_parent_objects = options_hash.delete(:expire_page_for_parent_objects) || []
    end
  end

  # define all instance methods in this module
  # (e.g. c = Category.find(12); c.my_instance_method)
  module InstanceMethods
    public

    def expire_page
#      klass_name = self.class.name.downcase
      # expire my pages
      self.class.expire_pages.each do |page|
        if page.to_s.include?('rewrite')
          _expire_page(eval("#{page}(create_rewrite_hash(self.rewrite))"))
        else
          _expire_page(eval("#{page}(self)"))
        end
      end
      # expire my parents pages
      self.class.expire_page_for_parent_objects.each do |parent|
        eval("
            if self.#{parent}.is_a?(Array)
              # has_many or has_and_belongs_to_many
              self.#{parent}.each do |el| 
                el.expire_page
              end
            else
              # has_one or belongs_to
              self.#{parent}.expire_page
            end
        ")
      end
    end
    
    private
    
    def expire_page_cache_sweeper_handler
      expire_page
    end

    def _expire_page(*args)
#      ActionController::Base.new.expire_page(*args)
      unless args.empty?
        file = args.first.gsub(/^\//, '')
        unless file.blank?
          directory = ActionController::Base.page_cache_directory
          file_name = directory + args.first
          File.delete(file_name) if File.exist?(file_name)
        end
      end
    end

    def before_save_cache_sweeper_handler
      #@changes = self.changes
    end

    def after_create_cache_sweeper_handler
      _expire_page(root_path)
      expire_page_cache_sweeper_handler
    end

    def after_update_cache_sweeper_handler
      expire_page_cache_sweeper_handler
    end

    def after_destroy_cache_sweeper_handler
      _expire_page(root_path)
      expire_page_cache_sweeper_handler
    end
  end
end
