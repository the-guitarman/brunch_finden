class TimedSweeper < BaseSweeper
  def daily
    expire_page(root_path)
    
    Rails.cache.write(frontend_index_locations)
    expire_fragment(frontend_index_ct_states)
    expire_fragment(frontend_index_ct_latest_reviews)
    expire_fragment(frontend_index_ct_city_with_most_locations)
    expire_fragment(frontend_index_ct_latest_coupons)
    
    expire_fragment('frontend_common_ct_header')
    expire_fragment('frontend_common_ct_footer')
    
    cache_page(root_path)
    
    true
  end
end