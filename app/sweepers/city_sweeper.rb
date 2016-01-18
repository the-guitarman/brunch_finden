class CitySweeper < BaseSweeper
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
    get_rewrites(object).each do |rewrite|
      path = city_rewrite_cache_key(rewrite)
      #puts "-- CitySweeper - App.expire_action('#{path}')"
      #App.expire_action(path)
      Rails.cache.delete_matched(/#{path}/)
    end
    
    if create_cache_again
      limit = (@@fec['CITIES']['SHOW']['LIMIT']['LOCATIONS'] || 20 rescue 20)
      count = object.locations.showable.count
      (count.to_f/limit).ceil.times do |idx|
        page = idx + 1
        path = city_rewrite_cache_key(object.rewrite, {:page => (page > 1 ? page : nil)})
        #cache_page(path)
        #puts "-- CitySweeper - path: #{path}"
        ptc = PathToCache.find_or_create(path)
        #puts "-- CitySweeper - ptc: #{ptc.errors.inspect}"
        #puts "-- CitySweeper - create_cache_again: #{path}"
      end
    end
    
    #StateSweeper.instance.expire_caches(object.state) if expire_parent
    object.state.touch if expire_parent
    true
  end
end