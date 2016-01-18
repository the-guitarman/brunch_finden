# CouponHandlerTriggeredSweeper is a singleton class.
# Usage: 
# - call CouponHandlerTriggeredSweeper.instance.run manually
class CouponHandlerTriggeredSweeper < BaseSweeper
  BATCH_SIZE = GLOBAL_CONFIG[:find_each_batch_size]
  
  def run    
    expire_fragment('frontend_index_ct_latest_coupons')
    expire_page(root_path)
    cache_page(root_path)
    
    expire_page(coupons_path)
    cache_page(coupons_path)
    
    expire_page(coupon_categories_path)
    cache_page(coupon_categories_path)
    
    CouponCategory.find_each({:batch_size => BATCH_SIZE}) do |cc|
      expire_page(coupon_category_path({:rewrite => cc.rewrite}))
      cache_page(coupon_category_path({:rewrite => cc.rewrite}))
    end
    
    #Rails.cache.delete_by_tags ['all_coupon_merchants']
    #delete_by_tags ['all_coupon_merchants']
    #expire_page(all_coupon_merchants_path)
    cache_page(all_coupon_merchants_path)
    fec = CustomConfigHandler.instance.frontend_config
    pp = (fec['COUPONS']['ALL_COUPON_MERCHANTS']['LIMIT']['COUPON_MERCHANTS'] || 20 rescue 20)
    coupons = Coupon.showable.paginate({:group => :merchant_id, :page => 1, :per_page => pp})
    (2..(coupons.total_pages - 1)).each do |page|
      cache_page(all_coupon_merchants_path({:page => page}))
    end
    
    
    Coupon.find_each({:batch_size => BATCH_SIZE, :group => :merchant_id}) do |c|
      expire_page(merchant_coupons_path({:merchant_id => c.merchant_id}))
      cache_page(merchant_coupons_path({:merchant_id => c.merchant_id}))
    end
    
    true
  end
end