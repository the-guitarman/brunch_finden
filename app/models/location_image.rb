require 'format_string'

class LocationImage < ActiveRecord::Base
  include Mixins::SecureCode
  secure_code_for :confirmation_code
  
  belongs_to :location, :touch => true
  belongs_to :frontend_user
  belongs_to :data_source
  
  UNPUBLISHED_VALID_FOR = 48 # hours
  
  PRESENTATION_TYPES = ['location','result']
  
  NEW_IMAGE_STATE = 'new'
  CHECKED_IMAGE_STATE = 'checked'
  IMAGE_STATES = [NEW_IMAGE_STATE, CHECKED_IMAGE_STATE]
  
  IMAGE_DIRECTORY = 'public/system/originals/location_images'
  
  NO_IMAGE = 'no_location_image.png'
  
  # This are all sizes an image can be displayed with. 
  IMAGE_RENDER_SIZES = {
    :list     => '75x75',
    :location => '230x230',
    :fancybox => '800x600'
  }
  
  IMAGE_CACHE_FORMAT = :png
  
  # The minimum upload size is 100x100.
  MINIMUM_UPLOAD_SIZE = 100
  
  SET_WATERMARK = {
    0 => nil,
    1 => CustomConfigHandler.instance.frontend_config['DOMAIN']['FULL_NAME'],
    2 => Proc.new{|location_image| "Bild hochgeladen von #{location_image.frontend_user.name} auf #{CustomConfigHandler.instance.frontend_config['DOMAIN']['FULL_NAME']}"}
  }
  DEFAULT_WATERMARK = 2

  named_scope(:main, {:conditions => {:is_main_image => true}})
  named_scope(:non_main, {:conditions => {:is_main_image => false}})
  named_scope(:showable, {
    :conditions => ["is_hidden = ? AND is_deleted = ? AND status <> 'tmp'", false, false],
    :order => 'is_main_image DESC, id ASC'
  })
  named_scope(:location_type, {:conditions => {:presentation_type => 'location'}})
  named_scope(:result_type, {:conditions => {:presentation_type => 'result'}})
  named_scope(:published, {:conditions => {:published => true}})
  named_scope(:unpublished, {:conditions => {:published => false}})
  
  before_validation :check_status
  before_validation :check_is_main_image

  validates_inclusion_of :presentation_type, :in => PRESENTATION_TYPES, 
    :message=>"value have to be: #{PRESENTATION_TYPES.to_sentence(
      :words_connector => 'or', :last_word_connector=> '')}"
  validates_inclusion_of :status, :in=>IMAGE_STATES,
    :message=>"value have to be: #{IMAGE_STATES.to_sentence(
      :words_connector => 'or', :last_word_connector=> '')}"
  validates_presence_of :location, :on => :create
  validates_presence_of :location_id, :on => :update
  validates_presence_of :data_source_id, :message => "The image needs a data source."
  validates_acceptance_of :general_terms_and_conditions,
    :allow_nil => false,
    :accept    => true
  
  validate :check_main_image_conditions
  validate :check_image_size

  acts_as_fleximage do
    image_directory IMAGE_DIRECTORY
    #validates_image_size "#{MINIMUM_UPLOAD_SIZE}x#{MINIMUM_UPLOAD_SIZE}"
    image_storage_format :png
    default_image_path "#{Rails.root}/public/images/#{NO_IMAGE}"
    require_image true
    use_creation_date_based_directories false
    output_image_jpg_quality 100 # 0 - 100 %, defaults to 85, only jpg format
    default_image nil
    
    preprocess_image do |image|
      image.resize '1280x1024'
    end
  end
  # Mixins::ImageCacheSweeper needs to be included direct below the inclusion of 
  # the acts_as_fleximage method. Otherwise fatal errors will happen. 
  include Mixins::ImageCacheSweeper
  
  after_create :touch_associated
  before_save :cleanup_image_tags, :check_watermark_flag
  after_save :set_main_image, :update_file_size
  after_destroy :select_other_main_image, :touch_associated


  # PUBLIC INSTANCE METHODS ----------------------------------------------------

  # Returns the image cache path, which is expected for this object in 
  # addition with the given options. It does not check wether the object 
  # has an image file or not.
  def get_image_cache_path(options={})
    size = options[:size] = options[:size].to_s.to_sym
    unless IMAGE_RENDER_SIZES.keys.include?(size)
      raise "The option :size has to be one of: #{IMAGE_RENDER_SIZES.keys.inspect}"
    end
    format = options[:format] = options[:format].to_s.to_sym
    unless [:jpg, :gif, :png].include?(format)
      format = IMAGE_CACHE_FORMAT 
    end
    if self.id.to_i == 0
      seo_name = '/no-location-image'
    else
      if (seo_name = options[:seo_name]).blank?
        if (seo_name = self.title).blank?
          seo_name = self.location.name
        end
      end
      seo_name = seo_name.to_s.downcase.parameterize
      seo_name = I18n.transliterate(seo_name)
      FormatString.normalize_charset!(seo_name)
      seo_name = "/#{seo_name}"
    end
    path = "#{GLOBAL_CONFIG[:location_images_cache_dir]}/" +
        "#{self.url_directory}/" +
        "#{self.id}/#{size}#{seo_name}.#{format}"
    return path
  end
  
  # Returns all image cache paths, which are used for this object. 
  def get_all_image_cache_paths
    page_cache_directory = ActionController::Base.page_cache_directory.to_s
    page_cache_directory = page_cache_directory.split('/').join('/')
    paths = Dir.glob("#{page_cache_directory}#{GLOBAL_CONFIG[:location_images_cache_dir]}/" +
      "#{self.url_directory}/#{self.id}/**/*.*".gsub('//', '/'))
    return paths.map{|p| p.gsub(/^#{page_cache_directory}/, '')}
  end

  # Returns true if image isn't hidden nor deleted.
  def is_showable
    return true unless self.is_hidden or self.is_deleted or self.status == "tmp"
  end
  
  def review
    if self.frontend_user
      #review = Review.where({
      #  :destination_type => 'Location',
      #  :destination_id => self.location_id,
      #  :frontend_user_id => self.frontend_user.id
      #}).first
      review = Review.find(:first, {
        :conditions => {
          :destination_id   => self.location_id, 
          :destination_type => 'Location',
          :frontend_user_id => self.frontend_user.id
        }
      })
      return review
    end
    nil
  end
  
  # CLASS METHODS --------------------------------------------------------------

  # Delivers the no_image image (public/images/no_image.png).
  def self.get_noimage_image
    image = new({:title => "no image"})
    image.id = 0
    def image.file_path
      "#{Rails.root}/public/images/#{NO_IMAGE}"
    end
    return image
  end
  
  # PROTECTED INSTANCE METHODS -------------------------------------------------

 protected

  def check_main_image_conditions
    # if image set to main image and
    # - is not showable
    # - it's presentation type is result
    # return false
    if self.is_main_image
      #if !self.is_showable or self.presentation_type != 'location' or self.uploader_denied_main_image
      if !self.is_showable or self.uploader_denied_main_image
        msg = "image is hidden!" unless self.is_showable
#        msg = "presentation type isn't 'location'!" unless self.presentation_type == 'location'
        msg = "uploader doesn't permit it!" if self.uploader_denied_main_image
        self.errors.add(:is_main_image, "Can't set to main image - #{msg}")
      end
    end
  end


  # PRIVATE INSTANCE METHODS ---------------------------------------------------

  private
  
  def check_status
    self.status = NEW_IMAGE_STATE unless self.status?
  end
  
  def check_is_main_image
    location_id = nil
    if self.location_id?
      location_id = self.location_id
    elsif self.location
      location_id = self.location.id
    end
    if location_id and self.is_main_image != true and self.uploader_denied_main_image == false
      former_main_image = self.class.find(:first, {
        :conditions => {
          :location_id => location_id,
          :is_main_image => true
        }
      })
      unless former_main_image
        self.is_main_image = true
      end
    end
  end

  def touch_associated
    self.location.touch
    self.review.touch if self.review
  end

  def check_image_size
    if self.image_width.blank? or self.image_width == 0 or 
       self.image_height.blank? or self.image_height == 0
      self.errors.add(:image_size, :invalid_image)
      return false
    end
    if self.image_width < MINIMUM_UPLOAD_SIZE and self.image_height < MINIMUM_UPLOAD_SIZE
      self.errors.add(:image_size, :image_too_small, :minimum => MINIMUM_UPLOAD_SIZE)
      return false
    end
    return true
  end

  # If this image is set to be the  main image,
  # then unset is_main_image flag on the old main image.
  def set_main_image
    if self.is_main_image
      self.class.update_all("is_main_image = 0", "is_main_image <> 0 AND location_id = #{self.location_id} AND id <> #{self.id}")
    end
  end

  # Unless this image has a file size or the file size changes, then update it.
  def update_file_size
    size = File.size(self.file_path)
    if !self.image_size? or self.image_size != size
      self.update_attributes({:image_size => size})
    end
  end

  # if image was the main image of the location then
  # try to elect a new main image
  def select_other_main_image
    if self.is_main_image
      new_main_image = self.class.showable.location_type.
        find(:first, {
          :conditions => {
            :location_id => self.location_id,
            :uploader_denied_main_image => false
          }
        })#.
        #first
      if new_main_image
        new_main_image.is_main_image = true
        new_main_image.save
      end
    end
  end

  # clear spaces from image tags
  def cleanup_image_tags
    self.tags = self.tags.strip
    unless self.tags.empty?
      tags = self.tags.split(",")
      tags_new = []
      tags.each do |item|
        tags_new.push(item.strip)
      end
      self.tags = tags_new.join(",")
    end
  end
  
  def check_watermark_flag
    self.set_watermark = DEFAULT_WATERMARK unless self.set_watermark
  end
end