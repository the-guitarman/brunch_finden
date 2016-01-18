#encoding: utf-8

require 'test_helper'

class Frontend::CouponsControllerTest < ActionController::TestCase
  fixtures :coupon_merchants
  
  # process before each test method
  def setup
    
  end

  # process after each test method
  def teardown

  end
  
  def test_index
    get :index
    assert_response :success
    assert_template 'frontend/coupons/index'
    #assert_template 'layouts/frontend/standard'
    assert_select 'head' do
      assert_select 'title', 'Gutscheine, Produktproben, Rabattgutscheine, Gewinnspiele und Coupons auf example.com'
    end
  end
  
  def test_show
    coupon = Coupon.first
    assert coupon.update_attributes({:valid_to => DateTime.now.tomorrow})
    c = Coupon.showable.first
    
    get :show, :id => c.id
    assert_response :success
    assert_template 'frontend/coupons/show'
    #assert_template 'layouts/frontend/standard'
    assert_select 'head' do
      assert_select 'title', 'Gutschein 1: 20,- € Gutschein für Neukunden von sheego - www.example.com'
    end
    
    # @coupon
    coupon = assigns(:coupon)
    assert_not_nil coupon
    assert_equal c.id, coupon.id
    
    # @page_header_tags
    pht = assigns(:page_header_tags)
    assert_not_nil pht
    assert pht.has_key?('title')
    assert_equal 'Gutschein 1: 20,- € Gutschein für Neukunden von sheego - www.example.com', pht['title']
    assert pht.has_key?('meta')
    assert pht['meta'].has_key?('description')
    assert_equal 'Gutschein 1: 20,- € Gutschein für Neukunden von sheego auf www.example.com', pht['meta']['description']
    assert pht['meta'].has_key?('keywords')
    assert_equal 'gutschein,coupon,example.com', pht['meta']['keywords']
    assert pht['meta'].has_key?('robots')
    assert_equal 'noindex, nofollow', pht['meta']['robots']
  end
  
  def test_show_via_xhr
    coupon = Coupon.first
    assert coupon.update_attributes({:valid_to => DateTime.now.tomorrow})
    c = Coupon.showable.first
    
    xhr :get, :show, :id => c.id
    assert_response :success
    assert_template 'frontend/coupons/_show_coupon'
    assert_equal Mime::HTML, response.content_type
    
    # @coupon
    coupon = assigns(:coupon)
    assert_not_nil coupon
    assert_equal c.id, coupon.id
    
    # @page_header_tags
    pht = assigns(:page_header_tags)
    assert pht.nil?
  end
  
  def test_all_coupon_merchants
    get :all_coupon_merchants
    assert :success
    assert_template 'frontend/coupons/all_coupon_merchants'
  end
  
  def test_merchant_coupons
    coupon = Coupon.first
    assert coupon.update_attributes({:valid_to => DateTime.now.tomorrow})
    coupon = Coupon.showable.first
    merchant_coupons_total = Coupon.showable.count({:conditions => {:merchant_id => coupon.merchant_id}})
    
    get :all_merchant_coupons, {:merchant_id => coupon.merchant_id}
    assert :success
    assert_template 'frontend/coupons/all_merchant_coupons'
    
    assert_select '#all-merchant-coupons > div.coupon', {:count => merchant_coupons_total}
  end
  
  def test_merchant_coupons_without_merchant
    get :all_merchant_coupons, {:merchant_id => 999999999999999999}
    assert_response :redirect
    assert_redirected_to(all_coupon_merchants_url)
  end
  
  def test_no_merchant_coupons_available
    cm = CouponMerchant.first
    
    cm.coupons.each do |c|
      assert c.update_attributes({:valid_to => DateTime.now.yesterday})
    end
    
    get :all_merchant_coupons, {:merchant_id => cm.merchant_id}
    assert :success
    assert_template 'frontend/coupons/all_merchant_coupons'
    
    # @merchant_coupons
    merchant_coupons = assigns(:merchant_coupons)
    assert merchant_coupons.is_a?(Array)
    assert merchant_coupons.empty?
    
    assert_select 'div#all-merchant-coupons' do
      #assert , "At the moment there are no coupons for #{cm.name} available.", 1
    end
  end
  
  def test_search
    
  end
end
