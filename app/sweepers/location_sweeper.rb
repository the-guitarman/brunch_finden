class LocationSweeper < BaseSweeper
#  observe Location
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
    rewrite_hashes = get_rewrite_hashes(object)
    
    rewrite_hashes.each do |rewrite_hash|
      path = location_rewrite_path(rewrite_hash)
      expire_page(path)
    end
    
    #if create_cache_again
    #  path = location_rewrite_path(create_rewrite_hash(object.rewrite))
    #  #cache_page(path)
    #  PathToCache.find_or_create(path)
    #  puts "-- LocationSweeper - create_cache_again: #{path}"
    #end
    
    #CityObserver.instance.expire_caches(object.zip_code.city) if expire_parent
    object.zip_code.city.touch if expire_parent
    true
  end
  
  def expire_caches_after_object_published(object, create_cache_again = true)
    expire_fragment(frontend_index_locations)
    expire_fragment(frontend_index_ct_latest_reviews)
    expire_fragment(frontend_index_ct_states)
    expire_fragment(frontend_index_ct_city_with_most_locations)
    expire_page(root_path)
    #cache_page(root_path) if create_cache_again
  end
end