#encoding: utf-8
require 'test_helper'

require 'jobs/coupon_handler'
require 'unit/helper/coupon_test_helper'

class CouponParserTest < ActiveSupport::TestCase
  include CouponTestHelper
  
  # process before each test method
  def setup
    
  end

  # process before each test method
  def teardown

  end

#  def test_run
#    file = "#{Rails.root}/tmp/test_detailed_coupons4u_de.xml"
#    detailed_xml_format = "#{Rails.root}/config/background/#{Rails.env}/coupons4u_de_xml_format_detailed.yml"
#    
#    Coupon.delete_all
#    CouponMerchant.delete_all
#    CouponCategory.delete_all
#    conn = ActiveRecord::Base.connection
#    conn.execute('DELETE FROM coupons_in_categories')
#    
#    block_to_test_it(file) do
#      assert CouponParser.new(file, detailed_xml_format).run
#    end
#    
#    assert_equal 10, Coupon.count
#    assert_equal 10, CouponMerchant.count
#    assert_equal 18, CouponCategory.count
#  ensure
#    File.delete(file) if File.exists?(file)
#  end

  def test_run
    file = "#{Rails.root}/tmp/test_detailed_coupons4u_de.xml"
    detailed_xml_format = "#{Rails.root}/config/background/#{Rails.env}/coupons4u_de_xml_format_detailed.yml"
    
    # keep old coupons, but their matches should be deleted
    c1 = Coupon.find_by_id(1)
    assert !c1.nil?
    assert c1.valid_to < DateTime.now
    assert_equal 1, c1.coupon_matches.count
    
    # keep old coupons and reset not_to_match flag
    c2 = Coupon.find_by_id(2)
    assert !c2.nil?
    assert_equal true, c2.not_to_match
    
    assert_equal 2, Coupon.count
    assert_equal 2, CouponMerchant.count
    assert_equal 47, CouponCategory.count
    
    conn = ActiveRecord::Base.connection
    conn.execute('DELETE FROM coupons_in_categories')
    
    block_to_test_it(file) do
      assert CouponParser.new(file, detailed_xml_format).run
    end
    
    # keep old coupons, but their matches should be deleted
    c1 = Coupon.find_by_id(1)
    assert !c1.nil?
    assert_equal 0, c1.coupon_matches(true).count
    
    # keep old coupons and reset not_to_match flag
    c2 = Coupon.find_by_id(2)
    assert !c2.nil?
    assert_equal false, c2.not_to_match
    
    assert_equal 12, Coupon.count
    assert_equal 10, CouponMerchant.count
    assert_equal 47, CouponCategory.count
  ensure
    File.delete(file) if File.exists?(file)
  end
end
