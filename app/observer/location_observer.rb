class LocationObserver < BaseObserver
  observe Location
  
  def after_create(object)
    destroy_forwarding(location_rewrite_path(create_rewrite_hash(object.rewrite)))
  end
  
  def after_save(object)
    changes = object.changes
    if forwarding_needed?(object, 'rewrite')
      create_forwarding(
        location_rewrite_path(create_rewrite_hash(changes['rewrite'][0])),
        location_rewrite_path(create_rewrite_hash(changes['rewrite'][1]))
      )
    end
    expire_caches(object, object.published)
    if changes.include?('published')# and 
       #(
       # (changes['published'][0] == nil and changes['published'][1] == true) or
       # (changes['published'][0] == true and changes['published'][1] == false)
       #)
      LocationSweeper.instance.expire_caches_after_object_published(object, true)
    end
  end
  
  def after_destroy(object)
    create_forwarding(
      location_rewrite_path(create_rewrite_hash(object.rewrite)),
      city_rewrite_path(create_rewrite_hash(object.zip_code.city.rewrite))
    )
    expire_caches(object, false)
  end

  def expire_caches(object, create_cache_again = true)
    LocationSweeper.instance.expire_caches(object, true, create_cache_again)
  end
end