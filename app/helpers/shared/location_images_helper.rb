# @api public
module Shared::LocationImagesHelper
  # @api public
  # Returns an location image path for a given image object. 
  # == Parameters
  # * image: the image (Class: {LocationImage})
  # * options: hash with render options like {:format => :png, :size => :normal}
  #   * :format: valid values (symbol or string) are: 
  #     :png, 'png', :jpg, 'jpg', :gif or 'gif' (defaults to :png)
  #   * :size: valid values are the keys of the {LocationImage::IMAGE_RENDER_SIZES LocationImage::IMAGE_RENDER_SIZES} hash
  #     A blank or an invalid size option causes an exception.
  #   * :seo_name: A human readable image name. If it's blank 
  #     the {Image#title Image#title} will be used.
  def get_location_image_path(image, options = {})
    size = options[:size] = options[:size].to_s
    unless LocationImage::IMAGE_RENDER_SIZES.keys.include?(size.to_sym)
      raise "The option :size has to be one of: #{LocationImage::IMAGE_RENDER_SIZES.keys.inspect}"
    end
    format = options[:format] = options[:format].to_s
    if format.blank? or not [:jpg, :gif, :png].include?(format.to_sym)
      format = options[:format] = LocationImage::IMAGE_CACHE_FORMAT 
    end
    if image.blank? or image.id == 0
      image = LocationImage.get_noimage_image
    elsif options[:alt].blank?
      if (seo_name = options[:seo_name]).blank?
        if (seo_name = image.title).blank?
          seo_name = image.location.name
        end
      end
      seo_name = seo_name.to_s.downcase.parameterize
      unless seo_name.blank?
        I18n.transliterate(seo_name)
        FormatString.normalize_charset!(seo_name)
        options[:alt] = seo_name
      end
    end
    return image.get_image_cache_path(options)
  end
  
  # @api public
  # Returns an location image path for a given image object. 
  # == Parameters
  # The method uses the same parameters like {Shared::LocationImagesHelper.get_location_image_path 
  # Shared::LocationImagesHelper.get_location_image_path}.
  #def get_location_image_url(image, options = {})
    #root_url.gsub(/\/$/, '') + get_location_image_path(image, options)
  #end
  
  # @api public
  # Returns a location image tag for a given object. 
  # == Parameters
  # Same as described for get_location_image_path.
  # * options: 
  #   * all valid html attributes
  #   * :alt: If not defined the alt attribute will be filled up with the 
  #     first 50 characters of the {Image#title Image#title} by default.
  def get_location_image_tag(image, options = {})
    image_url = get_location_image_path(image, {:format => options[:format], :size   => options[:size]})
    size = LocationImage::IMAGE_RENDER_SIZES[options[:size]]
    if options[:width] and options[:height]
      size = "#{options[:width]}x#{options[:height]}"
    end
    
    options.except!(:size, :format, :seo_name)
    
    image_url = 'http://' + @frontend_config['DOMAIN']['FULL_NAME'] + image_url
    image_tag(image_url, {:size => size, :itemprop => :image}.merge(options)).html_safe
  end
end
