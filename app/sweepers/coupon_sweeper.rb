class CouponSweeper < BaseSweeper
#  observe Coupon
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
    expire_page(coupon_path({:id => object.id}))
    #cache_page(coupon_path({:id => object.id})) if create_cache_again
    true
  end
end