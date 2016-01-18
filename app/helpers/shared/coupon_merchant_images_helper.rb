#encoding: utf-8

# @api public
module Shared::CouponMerchantImagesHelper
  # @api public
  # Returns a coupon_merchant image path for the given object. 
  # == Parameters
  # * coupon_merchant: The coupon_merchant object (Class: {CouponMerchant}.
  # * options: A hash with render options like {:format => :png, :size => :normal}
  #   * :image_type: (values: {CouponMerchant::IMAGE_TYPES CouponMerchant::IMAGE_TYPES})
  #   * :size: valid values are the keys of the {CouponMerchant::IMAGE_RENDER_SIZES CouponMerchant::IMAGE_RENDER_SIZES} hash
  #   * :format: valid values (symbol or string) are: 
  #     :png, 'png', :jpg, 'jpg', :gif or 'gif' (defaults to :png)
  def get_coupon_merchant_image_path(coupon_merchant, options = {})
    image_type = options[:image_type] = options[:image_type].to_s
    if image_type.blank? or not CouponMerchant::IMAGE_TYPES.include?(image_type)
      image_type = options[:image_type] = CouponMerchant::IMAGE_TYPES.first
    end
    size = options[:size] = options[:size].to_s
    if size.blank? or not CouponMerchant::IMAGE_RENDER_SIZES[image_type].keys.include?(size.to_sym)
      size = options[:size] = CouponMerchant::STANDARD_IMAGE_RENDER_SIZE[image_type]
    end
    format = options[:format] = options[:format].to_s
    if format.blank? or not [:jpg, :gif, :png].include?(format.to_sym)
      format = options[:format] = CouponMerchant::IMAGE_CACHE_FORMAT 
    end
    
    if coupon_merchant.blank? #or coupon_merchant.id == 0 or not coupon_merchant.has_image?
      coupon_merchant = CouponMerchant.get_noimage_image(image_type)
      options[:alt] = "no-image"
    else
      options[:alt] = coupon_merchant.name.parameterize if options[:alt].blank?
    end

    return coupon_merchant.get_image_cache_path(options).html_safe
  end
  
  # @api public
  # Returns a coupon_merchant image url for the given object. 
  # == Parameters
  # The method uses the same parameters like {Shared::CouponMerchantImagesHelper.get_coupon_merchant_image_path 
  # Shared::CouponMerchantImagesHelper.get_coupon_merchant_image_path}.
  #def get_coupon_merchant_image_url(coupon_merchant, options = {})
    #root_url.gsub(/\/$/, '').html_safe + get_coupon_merchant_image_path(coupon_merchant, options)
  #end
  
  # @api public
  # Returns a coupon_merchant image tag for a given coupon_merchant object. 
  # == Parameters
  # Same as described for get_coupon_merchant_image_path.
  # * options: 
  #   * :alt: If not defined the alt attribute will be filled up with the 
  #     {CouponMerchant#name CouponMerchant#name}
  #   * :image_type: One if {CouponMerchant::IMAGE_TYPES CouponMerchant::IMAGE_TYPES}
  #   * :size: It will be filled up with the value of the selected size 
  #     from {CouponMerchant::IMAGE_RENDER_SIZES CouponMerchant::IMAGE_RENDER_SIZES} by default.
  def get_coupon_merchant_image_tag(coupon_merchant, options={})
    image_url = get_coupon_merchant_image_path(coupon_merchant, options)
    size = CouponMerchant::IMAGE_RENDER_SIZES[options[:image_type]][options[:size]]
    if options[:width] and options[:height]
      size = "#{options[:width]}x#{options[:height]}"
    end
    
    options.except!(:size, :image_type, :format)
    
    image_tag(image_url, {:size => size}.merge(options)).html_safe
  end
end
