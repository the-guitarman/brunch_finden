class CouponMerchantSweeper < BaseSweeper
#  observe City
#  
#  def after_create(object)
#    
#  end
#  
#  def after_save(object)
#
#    expire_caches(object)
#  end
#  alias after_destroy after_save

  def expire_caches(object, expire_parent = true, create_cache_again = true)
    path = merchant_coupons_path({:merchant_id => object.merchant_id})
    #puts "-- CitySweeper - App.expire_action('#{path}')"
    #App.expire_action(path)
    Rails.cache.delete_matched(/#{path}/)
    
    if create_cache_again
      limit = (@frontend_config['COUPONS']['ALL_MERCHANT_COUPONS']['LIMIT']['COUPONS'] || 20 rescue 20)
      count = object.coupons.showable.count
      (count.to_f/limit).ceil.times do |idx|
        page = idx + 1
        parameters = {:merchant_id => object.merchant_id}
        parameters.merge!({:page => page}) if page > 1
        path = merchant_coupons_path(parameters)
        #cache_page(path)
        #puts "-- CitySweeper - path: #{path}"
        ptc = PathToCache.find_or_create(path)
        #puts "-- CitySweeper - ptc: #{ptc.errors.inspect}"
        #puts "-- CitySweeper - create_cache_again: #{path}"
      end
    end
    
    true
  end
end