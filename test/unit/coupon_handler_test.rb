#encoding: utf-8
require 'test_helper'

require 'jobs/coupon_handler'
require 'unit/helper/coupon_test_helper'

class CouponHandlerTest < ActiveSupport::TestCase
  include CouponTestHelper
  
  # process before each test method
  def setup
    
  end

  # process before each test method
  def teardown

  end

  def test_run
    file = "#{Rails.root}/tmp/test_detailed_coupons4u_de.xml"
    url = "file://#{file}"
    ch = CouponHandler.instance
    ch.instance_variable_set(:@uri, url)
    dest_xml_file = ch.instance_variable_get(:@dest_xml_file)
    tmp_xml_file = ch.instance_variable_get(:@tmp_xml_file)
    
    Coupon.delete_all
    CouponCategory.delete_all
    conn = ActiveRecord::Base.connection
    conn.execute('DELETE FROM coupons_in_categories')
    
    block_to_test_it(file) do
      assert ch.run
      assert (not File.exists?(dest_xml_file))
      assert (not File.exists?(tmp_xml_file))
    end
    
    assert_equal 10, Coupon.count
    assert_equal 18, CouponCategory.count
  ensure
    File.delete(dest_xml_file) if File.exists?(dest_xml_file)
    File.delete(tmp_xml_file) if File.exists?(tmp_xml_file)
  end
end
