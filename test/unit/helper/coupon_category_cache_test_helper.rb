# encoding: utf-8
require 'fileutils'
require 'unit/helper/cache_test_helper'

module CouponCategoryCacheTestHelper
  include CacheTestHelper
  
  def create_coupon_category_cache_files(coupon_category)
    create_action_cache(coupon_category_path({:rewrite => coupon_category.rewrite}))
  end
  
  def create_coupon_categories_cache_file
    create_page_cache(coupon_categories_path)
  end
  
  def check_coupon_category_cache_files_do_not_exist(coupon_category)
    action_cache_does_not_exist?(coupon_category_path({:rewrite => coupon_category.rewrite}))
  end
  
  def check_coupon_category_cache_file_does_not_exist
    page_cache_not_exists?(coupon_categories_path)
  end
end