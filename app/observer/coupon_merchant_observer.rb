class CouponMerchantObserver < BaseObserver
  observe CouponMerchant
  
  #def after_create(object)
  #  
  #end
  
  def after_save(object)
    expire_caches(object)
  end
  
  #def before_destroy(object)
  #  
  #end
  
  def after_destroy(object)
    expire_caches(object, false)
  end

  def expire_caches(object, create_cache_again = true)
    CouponMerchantSweeper.instance.expire_caches(object, create_cache_again)
  end
end