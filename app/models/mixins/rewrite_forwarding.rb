module Mixins::RewriteForwarding
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

      before_save   :before_save_rewrite_forwarding_handler

      after_create  :after_create_rewrite_forwarding_handler
      after_update  :after_update_rewrite_forwarding_handler
      after_destroy :after_destroy_rewrite_forwarding_handler
    end
  end

  # define all class methods in this module
  # (e.g. Category.my_class_method)
  module ClassMethods
    def acts_as_rewrite_forwardable(options_hash)
      cattr_accessor :parent_object, :parent_object_path, :parent_object_path_without_params,
        :object_path, :param_object_path
      
      # initialize class variables
      self.parent_object = options_hash.delete(:parent_object)
      self.parent_object_path = options_hash.delete(:parent_object_path)
      self.parent_object_path_without_params = options_hash.delete(:parent_object_path_without_params)
      self.object_path = options_hash.delete(:object_path)
      self.param_object_path = options_hash.delete(:param_object_path)
      
      #puts "--------- acts_as_rewrite_forwardable: #{options_hash.inspect}"
      if parent_object
        if parent_object_path.blank?
          raise("Missing :parent_object_path for acts_as_rewrite_forwardable")
        end
      end

      if object_path.blank?
        raise("Missing :object_path for acts_as_rewrite_forwardable")
      end
#      if param_object_path.blank?
#        raise("Missing :param_object_path for acts_as_rewrite_forwardable")
#      end

      class_eval "
        def _object_path(path)
          #{object_path}(_create_rewrite_hash(path))
        end

        def _param_object_path(path)
          #{param_object_path}(_create_rewrite_hash(path))
        end

        def _parent_object
          #{parent_object.blank? ? 'nil' : parent_object}
        end

        def _parent_object_path(path)
          #{parent_object_path}(_create_rewrite_hash(path))
        end

        def _parent_object_path_without_params
          #{parent_object_path_without_params}
        end
      
        def _create_rewrite_hash(path)
          unless path.is_a?(Integer)
            create_rewrite_hash(path)
          else
            path
          end
        end"
    end
  end

  # define all instance methods in this module
  # (e.g. c = Category.find(12); c.my_instance_method)
  module InstanceMethods
    
    private

    def before_save_rewrite_forwarding_handler
      @changes = self.changes
    end

    def after_create_rewrite_forwarding_handler
      # the new rewrite should not be forwarded
      rewrite = self.respond_to?(:rewrite) ? self.rewrite : self.id
      destroy_forwarding(rewrite)
    end

    def after_update_rewrite_forwarding_handler
      unless @changes.empty?
        if @changes.include?('rewrite')
          if (@changes['rewrite'][0] and self.rewrite?)
            # rewrite changed, so there's an old rewrite and a new one.
            # The old rewrite must be forwarded to the new one.
            check_and_add_forwarding_after_rewrite_change(
              @changes['rewrite'][0], self.rewrite
            )
          end
        end
      end
    end

    def after_destroy_rewrite_forwarding_handler
      # After this object is destroyed,
      # its rewrite will be forwarded to the parent rewrite.
      rewrite = self.respond_to?(:rewrite) ? self.rewrite : self.id
      add_forwarding_after_destroy(rewrite)
    end

    def add_forwarding_after_destroy(rewrite)
      new_destination = if self._parent_object.nil?
        if popwp = _parent_object_path_without_params
          popwp
        else
          root_path
        end
      else
        self._parent_object_path(self._parent_object.rewrite)
      end

      Forwarding.create({
        :source_url => self._object_path(rewrite),
        :destination_url => new_destination
      })
      if self.class.param_object_path
        Forwarding.create({
          :source_url => self._param_object_path(rewrite),
          :destination_url => new_destination
        })
      end
    end
    
    def add_forwarding_after_change(rewrite_old, rewrite_new)
      Forwarding.create({
        :source_url => self._object_path(rewrite_old),
        :destination_url => self._object_path(rewrite_new)
      })
      if self.class.param_object_path
        Forwarding.create({
          :source_url => self._param_object_path(rewrite_old),
          :destination_url => self._param_object_path(rewrite_new)
        })
      end
    end

    def check_and_add_forwarding_after_rewrite_change(rewrite_old, rewrite_new)
      # the new rewrite should not be forwarded
      destroy_forwarding(rewrite_new)
      # add the url forwarding from the old rewrite to the new one
      add_forwarding_after_change(rewrite_old, rewrite_new)
    end

    def destroy_forwarding(rewrite)
      # destroy all forwardings from this rewrite without to update each before
      Forwarding.update_last_use_at_on_find_enabled = false
      Forwarding.destroy_all({:source_url => self._object_path(rewrite)})
      if self.class.param_object_path
        Forwarding.destroy_all({:source_url => self._param_object_path(rewrite)})
      end
      Forwarding.update_last_use_at_on_find_enabled = true
    end
  end
end
