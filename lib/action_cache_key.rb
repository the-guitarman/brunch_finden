module ActionCacheKey
  def self.included(klass)
    klass.instance_eval do
      #extend ClassMethods
      include InstanceMethods
    end
  end
  
  module InstanceMethods  
    private
  
    def city_rewrite_cache_key(rewrite, params = {})
      parameters = create_rewrite_hash(rewrite)
      parameters[:page] = params[:page] if params.key?(:page)
      return city_rewrite_path(parameters)
    end
    
    def coupon_category_cache_key(coupon_category, params = {})
      parameters = params.copy
      parameters[:rewrite] = coupon_category.rewrite
      parameters.delete(:utf8)
      parameters.merge!({:date => coupon_category.updated_at.to_i})
      return coupon_category_path(parameters)
    end
    
    def merchant_coupons_cache_key(coupon_merchant, params = {})
      parameters = params.copy
      parameters[:merchant_id] = coupon_merchant.merchant_id
      parameters.delete(:utf8)
      parameters.merge!({:date => coupon_merchant.updated_at.to_i})
      return merchant_coupons_path(parameters)
    end
  
    def state_rewrite_cache_key_with_start_char(rewrite, params = {})
      return state_rewrite_path({
        :state => rewrite,
        city_char_parameter => params[city_char_parameter]#,
        #:date => params[:updated_at].to_i
      })
    end
  end
end