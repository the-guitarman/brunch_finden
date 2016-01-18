class CouponCategoryObserver < BaseObserver
  observe CouponCategory
  
  def after_create(object)
    destroy_forwarding(coupon_category_path({:rewrite => object.rewrite}))
  end
  
  def after_save(object)
    if forwarding_needed?(object, 'rewrite')
      changes = object.changes
      create_forwarding(
        coupon_category_path({:rewrite => changes['rewrite'][0]}),
        coupon_category_path({:rewrite => changes['rewrite'][1]})
      )
    end
    expire_caches(object)
  end
  
  def after_destroy(object)
    create_forwarding(
      coupon_category_path({:rewrite => object.rewrite}),
      coupon_categories_path
    )
    expire_caches(object, false)
  end

  def expire_caches(object, create_cache_again = true)
    CouponCategorySweeper.instance.expire_caches(object, create_cache_again)
  end
end