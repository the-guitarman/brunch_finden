module Mixins::ImageCacheSweeper
  def self.included(klass)
    klass.class_eval do
      alias original_post_save_in_image_cache_sweeper post_save
      def post_save
        original_post_save_in_image_cache_sweeper
        
        # If a new offer image is uploaded, all cached images will be deleted.
        if @uploaded_image
          #unless self.class.included_modules.include?(Mixins::OfferImagePreCacher)
            delete_all_cached_images
          #end
        end
      end
    end

    klass.instance_eval do
#      extend ClassMethods
      include InstanceMethods

      if klass.is_model_class?
        # if klass is an ActiveRecord::Base class,
        # then callbacks should be used,
        # otherwise the definition of a callback will raise an error
        
        # After object is destroyed, all cached images will be deleted.
        after_destroy :after_destroy_image_cache_sweeper_handler
      end
    end
  end
  
#  module ClassMethods
#    
#  end
  
  module InstanceMethods
    def delete_image
      File.delete(self.file_path) if File.exist?(self.file_path)
      delete_all_cached_images
    end
    
    # Returns the image cache path, which is expected for this object in 
    # addition with the given options. It does not check wether the object 
    # has an image file or not.
    def get_image_cache_path(options={})
      raise "No 'get_image_cache_path' instance method defined for #{self.class.name}."
    end
    
    # Returns all image cache paths, which are used for this object. 
    def get_all_image_cache_paths
      raise "No 'get_all_image_cache_paths' instance method defined for #{self.class.name}."
    end
    
    # Deletes all cached images of the object.
    def delete_cached_images
      delete_all_cached_images
    end
    
    private
    
    def after_destroy_image_cache_sweeper_handler
      delete_all_cached_images
    end
    
    def delete_all_cached_images
      self.get_all_image_cache_paths.each do |path|
        full_path = ActionController::Base.page_cache_directory.to_s + path
        File.delete(full_path) if File.exist?(full_path)
      end
    end
  end
end