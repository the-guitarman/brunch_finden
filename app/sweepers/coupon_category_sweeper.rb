class CouponCategorySweeper < BaseSweeper
#  observe CouponCategory
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

  def expire_caches(object, create_cache_again = true)
    get_rewrites(object).each do |rewrite|
      path = coupon_category_path({:rewrite => rewrite})
      #puts "-- CitySweeper - App.expire_action('#{path}')"
      #App.expire_action(path)
      Rails.cache.delete_matched(/#{path}/)
    end
    
    if create_cache_again
      limit = (@frontend_config['COUPON_CATEGORIES']['SHOW']['LIMIT']['COUPONS'] || 20 rescue 20)
      count = object.coupons.showable.count
      (count.to_f/limit).ceil.times do |idx|
        page = idx + 1
        parameters = {:rewrite => object.rewrite}
        parameters.merge!({:page => page}) if page > 1
        path = coupon_category_path(parameters)
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