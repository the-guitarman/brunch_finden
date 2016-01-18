class StateSweeper < BaseSweeper
  
#  observe State
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
    rewrites = get_rewrites(object)
    rewrites.each do |rewrite|
      # expire/cache 
      path = state_rewrite_cache_key_with_start_char(rewrite)
      path = path.split('?').first.gsub(/^\//, '')
      #App.expire_action(path)
      Rails.cache.delete_matched(/#{path}/)
    end
    
    if create_cache_again
      object.city_chars.each do |cc|
        path = state_rewrite_cache_key_with_start_char(object.rewrite, {
          city_char_parameter => cc.start_char.upcase
        })
        #puts "-- StateSweeper - path: #{path}"
        #cache_page(path)
        ptc = PathToCache.find_or_create(path)
        #puts "-- StateSweeper - ptc: #{ptc.errors.inspect}"
        #puts "-- StateSweeper - create_cache_again: #{path}"
      end
    end
    
    true
  end
end