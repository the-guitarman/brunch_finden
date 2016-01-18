class Shared::ImagesController < ApplicationController
  before_filter :set_expires_in
  
  skip_before_filter :set_page_header_tag_configurator
  skip_before_filter :set_page_header_tags

  caches_page :get_coupon_merchant_image, :get_location_image
  
  #cache_sweeper :image_sweeper, :only=>:destroy

  def get_coupon_merchant_image
    coupon_merchant_id = params[:id].to_i
    @size_key = params[:size].to_s.to_sym
    format_key = CouponMerchant::IMAGE_CACHE_FORMAT #params[:format].to_s.to_sym
    @image_type = params[:image_type].to_s
    @size = CouponMerchant::IMAGE_RENDER_SIZES[@image_type][@size_key]
    @coupon_merchant = CouponMerchant.get_noimage_image(@image_type)
    if coupon_merchant_id > 0
      coupon_merchant = CouponMerchant.find_by_id(coupon_merchant_id)
      if coupon_merchant
        @coupon_merchant = coupon_merchant
      else
        redirect_to(@coupon_merchant.get_image_cache_path(params), {:status => 302})
        return false # to don't cache anything
      end
    end
    render :template => "shared/images/get_coupon_merchant_image.#{format_key}.flexi"
  end
  
  def get_location_image
    @watermark_file_name = nil #"#{Rails.root}#{@frontend_config['SHARED']['IMAGES']['WATERMARK_IMAGE']}"
    image_id  = params[:id].to_i
    size_key   = params[:size].to_s.to_sym
    format_key = LocationImage::IMAGE_CACHE_FORMAT #params[:format].to_s.to_sym
    @size = LocationImage::IMAGE_RENDER_SIZES[size_key]
    @image = LocationImage.get_noimage_image
    if image_id > 0
      image = LocationImage.find_by_id(image_id)
      if image and image.has_image?
        @image = image
      else
        redirect_to(@image.get_image_cache_path(params), {:status => 302})
        return false # to don't cache anything
      end
    end
    render :template => "shared/images/get_location_image.#{format_key}.flexi"
  end
  
  private
  
  def set_expires_in
    expires_in 1.day.seconds, :public=>true
  end
end
