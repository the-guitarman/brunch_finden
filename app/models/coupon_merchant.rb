class CouponMerchant < ActiveRecord::Base
  include Mixins::TextCleaner
  clean_text_in(:name, :description, {
    :action_formatter => {
      :replace_newlines => "\n", 
      :format_headlines => 'remove', 
      :ascii_art        => 'remove', 
      :html_optimize    => 'all', 
      :html_filter      => 'all'
    }
  })

  IMAGE_DIRECTORY = 'public/system/originals/coupon_merchant'

  # @api public
  IMAGE_TYPES = ['logo']

  IMAGE_UPLOAD_SIZES = {
    IMAGE_TYPES[0] => '120x60'
  }

  # @api public
  IMAGE_RENDER_SIZES = {
    IMAGE_TYPES[0] => {
      :small  => '80x30'
    }
  }

  # @api public
  STANDARD_IMAGE_RENDER_SIZE = {
    IMAGE_TYPES[0] => :small
  }

  # @api public
  IMAGE_CACHE_FORMAT = :jpg

  # @api public
  NO_IMAGE = {
    IMAGE_TYPES[0] => 'no_coupon_merchant_logo.png'
  }
  acts_as_fleximage do
    image_directory IMAGE_DIRECTORY
    image_storage_format :png
    require_image false
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

  has_many :coupons, :foreign_key => :merchant_id, :primary_key => :merchant_id, :dependent => :destroy
  
  validates_presence_of :merchant_id, :name
  validates_uniqueness_of :merchant_id
  validates_numericality_of :number_of_coupons, :greater_than_or_equal_to => 0
  
  before_create :download_logo
  before_update :download_logo
  
  named_scope :showable, :conditions => 'number_of_coupons > 0'

  # Returns the image cache path, which is expected for this object in
  # addition with the given options. It does not check wether the object
  # has an image file or not.
  def get_image_cache_path(options={})
    image_type = options[:image_type] = options[:image_type].to_s
    if image_type.blank? or not IMAGE_TYPES.include?(image_type)
      image_type = options[:image_type] = IMAGE_TYPES.first
    end
    size = options[:size] = options[:size].to_s
    if size.blank? or not IMAGE_RENDER_SIZES[image_type].keys.include?(size.to_sym)
      size = STANDARD_IMAGE_RENDER_SIZE[image_type]
    end
    format = options[:format] = options[:format].to_s
    if format.blank? or not [:jpg, :gif, :png].include?(format.to_sym)
      format = IMAGE_CACHE_FORMAT
    end

    path = "#{GLOBAL_CONFIG[:coupon_merchant_images_cache_dir]}/" +
        "#{image_type}/" +
        "#{size}/" +
        "#{self.url_directory}/" +
        "#{self.id}.#{format}"
    return path
  end

  # Returns all image cache paths, which are used for this object.
  def get_all_image_cache_paths
    page_cache_directory = ActionController::Base.page_cache_directory.to_s
    page_cache_directory = page_cache_directory.split('/').join('/')
    all_irs_keys = IMAGE_RENDER_SIZES.values.map{|v| v.keys}.flatten.uniq.join(',')
    paths = Dir.glob("#{page_cache_directory}#{GLOBAL_CONFIG[:coupon_merchant_images_cache_dir]}/" +
      "{#{IMAGE_TYPES.join(',')}}/{#{all_irs_keys}}/" +
      "#{self.url_directory}/#{self.id}.*".gsub('//', '/'))
    return paths.map{|p| p.gsub(/^#{page_cache_directory}/, '')}
  end
  
  def update_statistics
    self.number_of_coupons = self.coupons.showable.count
    self.save
  end
  
  def self.update_statistics
    find_each do |cm|
      cm.update_statistics
    end
  end

  # delivers the no_image image
  def self.get_noimage_image(image_type = IMAGE_TYPES[0])
    unless IMAGE_TYPES.include?(image_type)
      raise "image_type has to be one of: [#{IMAGE_TYPES.join(', ')}]"
    end
    object = new({:name => 'no logo'})
    object.id = 0
    eval("def object.file_path;'#{Rails.root}/public/images/#{NO_IMAGE[image_type]}';end")
    return object
  end
  
  private
  
  def download_logo
    if self.logo_url?
      if self.new_record? or (self.logo_url_changed? and not self.has_image?)
        self.image_file_url = self.logo_url
      end
    end
  end
end