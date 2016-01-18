#encoding: utf-8

require 'test_helper'

class Frontend::CouponCategoriesControllerTest < ActionController::TestCase
  fixtures :coupon_categories
  
  # process before each test method
  def setup
    
  end

  # process after each test method
  def teardown

  end
  
  def test_index
    get :index
    assert_response :success
    assert_template 'frontend/coupon_categories/index'
    #assert_template 'layouts/frontend/standard'
    assert_select 'head' do
      assert_select 'title', 'Alle Gutschein-Kategorien - www.example.com'
    end
    
    coupon_categories = assigns(:coupon_categories)
    assert_not_nil coupon_categories
    assert coupon_categories.is_a?(Array)
    assert_equal 5, coupon_categories.length
  end
  
  def test_show
    cc = CouponCategory.first
    
    get :show, :rewrite => cc.rewrite
    assert_response :success
    assert_template 'frontend/coupon_categories/show'
    #assert_template 'layouts/frontend/standard'
    assert_select 'head' do
      assert_select 'title', 'Umfragen Gutscheine - www.example.com'
    end
    
    # @coupon_category
    coupon_category = assigns(:coupon_category)
    assert_not_nil coupon_category
    assert_equal cc, coupon_category    
    
    # @page
    page = assigns(:page)
    assert_not_nil page
    assert_equal 1, page
    
    # @coupon_category_limit
    coupon_category_limit = assigns(:coupon_category_limit)
    assert_not_nil coupon_category_limit
    assert_equal 20, coupon_category_limit
    
    # @coupons
    coupons = assigns(:coupons)
    assert_not_nil coupons
    assert coupons.is_a?(Array)
    assert_equal 0, coupons.length
    
    # @page_header_tags
    pht = assigns(:page_header_tags)
    assert_not_nil pht
    assert pht.has_key?('title')
    assert_equal 'Umfragen Gutscheine - www.example.com', pht['title']
    assert pht.has_key?('meta')
    assert pht['meta'].has_key?('description')
    assert_equal 'Umfragen Gutscheine suchen und finden auf www.example.com', pht['meta']['description']
    assert pht['meta'].has_key?('keywords')
    assert_equal 'Umfragen,gutscheine,coupons,finden,suchen,search,example.com', pht['meta']['keywords']
    assert pht['meta'].has_key?('robots')
    assert_equal 'noindex, noarchive, follow', pht['meta']['robots']
  end
  
  def test_show_without_coupon_category
    get :show, {:rewrite => 'unknown-coupon-category'}
    assert_response :redirect
    assert_redirected_to(coupon_categories_url)
  end
end
