# encoding: utf-8
require 'fileutils'
require 'unit/helper/cache_test_helper'

module CouponCacheTestHelper
  include CacheTestHelper
  
  def create_coupon_cache_files(coupon)
    create_page_cache(coupon_path(coupon))
  end
  
  def check_coupon_cache_files_do_not_exist(coupon)
    page_cache_not_exists?(coupon_path(coupon))
  end
end