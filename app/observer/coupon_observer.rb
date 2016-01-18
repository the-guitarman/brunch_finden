class CouponObserver < BaseObserver
  observe Coupon
  
  def after_create(object)
    destroy_forwarding(coupon_path({:id => object.id}))
  end
  
  def after_save(object)
    if forwarding_needed?(object, 'id')
      changes = object.changes
      create_forwarding(
        coupon_path({:id => changes['id'][0]}),
        coupon_path({:id => changes['id'][1]})
      )
    end
    expire_caches(object)
  end
  
  def before_destroy(object)
    
  end
  
  def after_destroy(object)
    coupon_categories_ids = object.instance_variable_get(:@coupon_categories_ids)
    coupon_categories = CouponCategory.find(:all, :conditions => {:id => coupon_categories_ids})
    create_forwarding(
      coupon_path({:id => object.id}),
      coupon_category_path({:rewrite => coupon_categories.first.rewrite})
    )
    expire_caches(object, false)
  end

  def expire_caches(object, create_cache_again = true)
    CouponSweeper.instance.expire_caches(object, create_cache_again)
  end
end