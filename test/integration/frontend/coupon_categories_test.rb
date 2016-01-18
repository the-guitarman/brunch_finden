require File.dirname(__FILE__) + '/../../test_helper'

class Frontend::CouponCategoriesTest < ActionController::IntegrationTest
  # process before each test method
  def setup

  end

  # process after each test method
  def teardown

  end

  def test_index
    
  end

  def test_show
    
  end

#  def test_action_cache
#    begin
#      # force the controller to be reloaded when caching is enabled
#      ActionController::Base.perform_caching = true
#      load "frontend/coupon_categories_controller.rb"
#      
#      cc = CouponCategory.first
#      
#      path = coupon_category_cache_key(cc)
#      puts "-- path: #{path}"
#      
#      delete_action_cache(path)
#      
#      action_cache_does_not_exist?(path)
#      
#      get path
#      assert_response :success
#      action_cache_exist?(path)
#      
#      cc.number_of_coupons += 1
#      cc.save
#      action_cache_does_not_exist?(path)
#      
#      get path
#      assert_response :success
#      action_cache_exist?(path)
#    ensure
#      # undo the actions above
#      ActionController::Base.perform_caching = false
#      load "frontend/coupon_categories_controller.rb"
#
#      delete_action_cache(path)
#    end
#  end
end