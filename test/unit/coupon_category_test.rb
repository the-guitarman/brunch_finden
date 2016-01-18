#encoding: utf-8
require 'test_helper'

require 'unit/helper/cache_test_helper'
require 'unit/helper/coupon_category_cache_test_helper'

class CouponCategoryTest < ActiveSupport::TestCase
  include CouponCategoryCacheTestHelper
  
  # process before each test method
  def setup
    
  end

  # process before each test method
  def teardown

  end

  def test_01_create
    cc_test_1 = CouponCategory.create
    assert !cc_test_1.valid?
    assert cc_test_1.errors.invalid?(:name)
    assert !cc_test_1.errors.invalid?(:number_of_coupons)
    
    cc = CouponCategory.create(valid_attributes)
    assert cc.valid?
    assert !cc.errors.invalid?(:name)
    assert !cc.errors.invalid?(:number_of_coupons)
    
    cc_test_2 = CouponCategory.create(valid_attributes)
    assert !cc_test_2.valid?
    assert cc_test_2.errors.invalid?(:name)
    assert !cc_test_2.errors.invalid?(:number_of_coupons)
    
    attributes = valid_attributes({:name => 'Sale Now', :number_of_coupons => -1})
    cc_test_3 = CouponCategory.create(attributes)
    assert !cc_test_3.valid?
    assert !cc_test_3.errors.invalid?(:name)
    assert cc_test_3.errors.invalid?(:number_of_coupons)
    
    attributes = valid_attributes({:name => 'Sale Now', :number_of_coupons => 'a'})
    cc_test_4 = CouponCategory.create(attributes)
    assert !cc_test_4.valid?
    assert !cc_test_4.errors.invalid?(:name)
    assert cc_test_4.errors.invalid?(:number_of_coupons)
  end

  def test_02_update
    cc = CouponCategory.first
    
    create_cache_files(cc)
    
    cc.name += 'new'
    assert cc.save
    
    check_cache_files_do_not_exist(cc)
  end

  def test_03_model_associations_constants_included_modules
    cc = CouponCategory.first
    
    assert_respond_to cc, :coupons
  end

  def test_04_destroy
    cc = CouponCategory.first
    
    create_cache_files(cc)
    
    cc.destroy
    assert cc.frozen?
    
    check_cache_files_do_not_exist(cc)
  end

  private

  def valid_attributes(add_attributes={})
    {
      :name => 'Sale Sale Sale'
    }.merge(add_attributes)
  end

  def create_cache_files(coupon_category)
    create_coupon_category_cache_files(coupon_category)
    #create_coupon_categories_cache_file
  end

  def check_cache_files_do_not_exist(coupon_category)
    check_coupon_category_cache_files_do_not_exist(coupon_category)
    #check_coupon_category_cache_file_does_not_exist
  end
end
