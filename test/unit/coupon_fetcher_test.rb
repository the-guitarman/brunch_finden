#encoding: utf-8
require 'test_helper'

require 'jobs/coupon_handler'
require 'unit/helper/coupon_test_helper'

class CouponFetcherTest < ActiveSupport::TestCase
  include CouponTestHelper
  
  # process before each test method
  def setup
    
  end

  # process before each test method
  def teardown

  end

  def test_run
    file = "#{Rails.root}/tmp/test_detailed_coupons4u_de"
    uri = "file://#{file}"
    dest_xml_file = "#{Rails.root}/tmp/test_detailed_coupons4u_de.xml"
    tmp_xml_file = "#{Rails.root}/tmp/test_detailed_coupons4u_de_tmp.xml"
    
    block_to_test_it(file) do
      assert CouponFetcher.new(dest_xml_file, tmp_xml_file, uri).run
      assert File.exists?(dest_xml_file)
      assert File.exists?(tmp_xml_file)
    end
  ensure
    File.delete(dest_xml_file) if File.exists?(dest_xml_file)
    File.delete(tmp_xml_file) if File.exists?(tmp_xml_file)
  end
end
