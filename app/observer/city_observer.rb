class CityObserver < BaseObserver
  observe City
  
  def after_create(object)
    destroy_forwarding(city_rewrite_path(create_rewrite_hash(object.rewrite)))
  end
  
  def after_save(object)
    if forwarding_needed?(object, 'rewrite')
      changes = object.changes
      create_forwarding(
        city_rewrite_path(create_rewrite_hash(changes['rewrite'][0])),
        city_rewrite_path(create_rewrite_hash(changes['rewrite'][1]))
      )
    end
    expire_caches(object)
  end
  
  def after_destroy(object)
    create_forwarding(
      city_rewrite_path(create_rewrite_hash(object.rewrite)),
      state_rewrite_path(create_rewrite_hash(object.state.rewrite))
    )
    expire_caches(object, false)
  end
  
  def expire_caches(object, create_cache_again = true)
    CitySweeper.instance.expire_caches(object, true, create_cache_again)
  end
end