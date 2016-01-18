#module Mixins::HasImage   
##  # @api public
##  MAX_HEIGHT_RATIO = 1.5 # 3:2 format photos
##  IMAGE_RENDER_SIZES = {
##    IMAGE_TYPES[0] => {
##      :avatar          => '60x60',
##      :milestone       => '100x100',
##      :my_yopi         => '186',
##      :my_yopi_gallery => '190x190',
##      :my_yopi_list    => '70'
##    }
##  }
##  
##  # @api public
##  STANDARD_IMAGE_RENDER_SIZE = {
##    IMAGE_TYPES[0] => :avatar
##  }
##  
##  # @api public
##  NR_PROFILE_IMAGES = 6
##  
##  # @api public
##  NO_IMAGE = {
##    IMAGE_TYPES[0] => 'no_image_frontend_user___GENDER__.png'
##  }
#  
##  acts_as_fleximage do
##    image_directory IMAGE_DIRECTORY
##    image_storage_format :png
##    require_image true
##    use_creation_date_based_directories false
##    output_image_jpg_quality 100 # 0 - 100 %, defaults to 85, only jpg format
##    default_image nil
##    
##    preprocess_image do |image|
##      image.resize '1280x1024'
##    end
##  end
#  # Mixins::ImageCacheSweeper needs to be included direct below the inclusion of 
#  # the acts_as_fleximage method. Otherwise fatal errors will happen. 
##  include Mixins::ImageCacheSweeper
#
#  
#  def self.included(klass)
#    const_set(:KLASS, klass)
#    klass.instance_eval do
#      include InstanceMethods
#      extend ClassMethods
#    end
#  end
#  
#  module InstanceMethods
#    
#  end
#  
#  module ClassMethods
#    def init_has_image(options = {})
#      KLASS.const_set(:IMAGE_DIRECTORY, "public/system/originals/#{KLASS.name.underscore}_images")
#      
#      KLASS.const_set(:NEW_IMAGE_STATE, 'new')
#      KLASS.const_set(:CHECKED_IMAGE_STATE, 'checked')
#      KLASS.const_set(:IMAGE_STATES, [KLASS::NEW_IMAGE_STATE, KLASS::CHECKED_IMAGE_STATE])
#      
#      KLASS.const_set(:IMAGE_TYPES, options[:image_types])
#      
#      KLASS.const_set(:IMAGE_CACHE_FORMAT, :jpg)
#
#      KLASS.const_set(:IMAGE_UPLOAD_SIZES, {
#        KLASS::IMAGE_TYPES[0] => '60x60'
#      })
#    end
#  end
#end