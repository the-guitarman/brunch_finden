require File.dirname(__FILE__) + '/../../test_helper'

class Frontend::RoutesTest < ActionController::IntegrationTest
#        :compare_prices_in_city          => 'compare-prices',
#        :rewrite_prefix_city             => 'brunch',
#        :new_location                    => 'enter-a-new-brunch-location',
#        :new_location_suggestion         => 'suggest-a-new-brunch-location'

  def test_root_route
    assert_equal '/', root_path
    # index#index
    #assert_generates(root_path
    #  '/',
    #  {:controller => 'frontend/index', :action => 'index'}
    #)
    assert_recognizes_with_host(
      {
        :controller => 'frontend/index', :action => 'index',
        :namespace => nil, :subdomains => ['www']
      },
      {:path => '/', :method => :get, :host => 'www.example.com'}
    )
  end

  def test_exit_byebye_routes
    assert_routing_with_host({:path => '/exit'}, {:controller => 'frontend/exit', :action => 'byebye', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/bye'}, {:controller => 'frontend/exit', :action => 'bye', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
  end
  
  def test_miscellaneous_routes
    assert_routing_with_host({:path => '/error/404.html'}, {:controller => 'frontend/errors', :action => 'show', :id => '404', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/social/123456789'}, {:controller => 'frontend/social', :action => 'show', :id => '123456789', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    
    assert_routing_with_host({:path => '/general-terms-and-conditions.html'}, {:controller => 'frontend/index', :action => 'general_terms_and_conditions', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/privacy-notice.html'}, {:controller => 'frontend/index', :action => 'privacy_notice', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/registration-information.html'}, {:controller => 'frontend/index', :action => 'registration_information', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/about-us.html'}, {:controller => 'frontend/index', :action => 'about_us', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/advertising-opportunities.html'}, {:controller => 'frontend/index', :action => 'advertising_opportunities', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
  end
  
  def test_captcha_routes
    assert_routing_with_host({:path => 'new-captcha'}, {:controller => 'frontend/common', :action => 'captcha', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
  end
  
  def test_city_routes
#    # city
#    map.connect "/:state/:city/#{I18n.t('shared.routes.compare_prices_in_city')}",
#      :controller => 'redirections', :action => :index, :state => STATE_PATTERN,
#      :new_path => '/:state/:city'
#    map.connect "/:state/:city/#{I18n.t('shared.routes.compare_prices_in_city')}/:page", 
#      #:controller => 'frontend/cities', :action => :compare_prices, :state => STATE_PATTERN,
#      :controller => 'redirections', :action => :index, :state => STATE_PATTERN,
#      :page => nil, :trailing_slash => false, :new_path => '/:state/:city/:page'
#    map.connect '/:state/:city.html', 
#      :controller => 'redirections', :action => :index, :state => STATE_PATTERN,
#      :type => 'frontend', :new_path => '/:state/:city'
#    map.city_rewrite '/:state/:city/:page', 
#      :controller => 'frontend/cities', :action => :show, :state => STATE_PATTERN,
#      :page => nil, :trailing_slash => false
#    map.search_by_name_frontend_cities '/frontend/cities/search_by_name', 
#      :controller => 'frontend/cities', :action => :search_by_name
#    map.search_by_zip_code_frontend_cities '/frontend/cities/search_by_zip_code', 
#      :controller => 'frontend/cities', :action => :search_by_zip_code
  end
  
  def test_coupon_routes  
    assert_routing_with_host({:path => '/coupons/suche.html'}, {:controller => 'frontend/coupons', :action => 'search', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/coupons'}, {:controller => 'frontend/coupons', :action => 'index', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/coupon/1'}, {:controller => 'frontend/coupons', :action => 'show', :id => '1', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
  end
  
  def test_coupon_categories_routes  
    assert_routing_with_host({:path => '/all-coupon-categories'}, {:controller => 'frontend/coupon_categories', :action => 'index', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/coupon-category/shoes'}, {:controller => 'frontend/coupon_categories', :action => 'show', :rewrite => 'shoes', :trailing_slash => false, :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/coupon-category/shoes/2'}, {:controller => 'frontend/coupon_categories', :action => 'show', :rewrite => 'shoes', :trailing_slash => false, :page => '2', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
  end
  
  def test_coupon_merchant_routes
    assert_routing_with_host(
      {:path => '/coupon_merchant_images/logo/list/1/1.png'}, 
      {:controller => 'shared/images', :action => 'get_coupon_merchant_image', :image_type => 'logo', :size => 'list', :id_sub_dir => '1', :id => '1', :format => 'png', :namespace => nil, :subdomains => ['www']}, 
      'www.example.com'
    )
    assert_routing_with_host({:path => '/coupons/alle-shops'}, {:controller => 'frontend/coupons', :action => 'all_coupon_merchants', :trailing_slash => false, :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/coupons/alle-shops/2'}, {:controller => 'frontend/coupons', :action => 'all_coupon_merchants', :trailing_slash => false, :page => '2', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/coupons/shop/1'}, {:controller => 'frontend/coupons', :action => 'all_merchant_coupons', :trailing_slash => false, :merchant_id => '1', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/coupons/shop/1/2'}, {:controller => 'frontend/coupons', :action => 'all_merchant_coupons', :trailing_slash => false, :merchant_id => '1', :page => '2', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
  end
  
  def test_location_routes
#    # location
#    map.location_rewrite '/:state/:city/:location.html', 
#      :controller => 'frontend/locations', :action => :show, :state => STATE_PATTERN
#    map.report_location_changes '/:state/:city/:location/report-changes', 
#      :controller => 'frontend/locations', :action => :report_changes, :state => STATE_PATTERN,
#      :conditions => {:method => :post}
#    map.report_location_changes '/:state/:city/:location/report-changes', 
#      :controller => 'frontend/locations', :action => :show_report_changes, :state => STATE_PATTERN,
#      :conditions => {:method => :get}
#    map.new_location_image '/:state/:city/:location/new-image', 
#      :controller => 'frontend/location_images', :action => :new, :state => STATE_PATTERN,
#      :conditions => {:method => :get}
#    map.create_location_image '/:state/:city/:location/new-image', 
#      :controller => 'frontend/location_images', :action => :create, :state => STATE_PATTERN,
#      :conditions => {:method => :post}
#    map.compare_locations "/locations/compare", :controller => 'frontend/locations', :action => :compare
#    map.new_location "/#{I18n.t('shared.routes.new_location')}.html", 
#      :controller => 'frontend/locations', :action => :new
#    map.frontend_locations '/frontend/locations', 
#      :controller => 'frontend/locations', :action => :create,
#      :conditions => {:method => :post}
#    map.check_frontend_locations '/frontend/locations/check', 
#      :controller => 'frontend/locations', :action => :check
#    map.confirm_frontend_location '/frontend/locations/:id/confirm', 
#      :controller => 'frontend/locations', :action => :confirm
  end
  
  def test_location_image_routes
    assert_routing_with_host(
      {:path => '/location_images/1/1/list/seo_name.png'}, 
      {:controller => 'shared/images', :action => 'get_location_image', :id_sub_dir => '1', :id => '1', :size => 'list', :seo_name => 'seo_name', :format => 'png', :namespace => nil, :subdomains => ['www']},
      'www.example.com'
    )
    assert_routing_with_host(
      {:path => '/location_images/1/1/list.png'}, 
      {:controller => 'shared/images', :action => 'get_location_image', :id_sub_dir => '1', :id => '1', :size => 'list', :format => 'png', :namespace => nil, :subdomains => ['www']},
      'www.example.com'
    )
    assert_routing_with_host(
      {:path => '/s/c/l/images/1/confirm/ABC'}, 
      {:controller => 'frontend/location_images', :action => 'confirm', :state => 's', :city => 'c', :location => 'l', :id => '1', :token => 'ABC', :namespace => nil, :subdomains => ['www']},
      'www.example.com'
    )
    assert_routing_with_host(
      {:path => '/s/c/l/images/1/delete/ABC'}, 
      {:controller => 'frontend/location_images', :action => 'delete', :state => 's', :city => 'c', :location => 'l', :id => '1', :token => 'ABC', :namespace => nil, :subdomains => ['www']},
      'www.example.com'
    )
    assert_routing_with_host(
      {:path => '/frontend/location_images/1/confirm'}, 
      {:controller => 'frontend/location_images', :action => 'confirm', :id => '1', :token => 'ABC', :namespace => nil, :subdomains => ['www']},
      'www.example.com',
      {}, {:token => 'ABC'}
    )
    assert_routing_with_host(
      {:path => '/frontend/location_images/1/delete'}, 
      {:controller => 'frontend/location_images', :action => 'delete', :id => '1', :token => 'ABC', :namespace => nil, :subdomains => ['www']},
      'www.example.com',
      {}, {:token => 'ABC'}
    )
  end
  
  def test_location_suggestion_routes
    assert_routing_with_host({:path => '/suggest-a-new-brunch-location.html'}, {:controller => 'frontend/location_suggestions', :action => 'new', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/frontend/location_suggestions', :method => :post}, {:controller => 'frontend/location_suggestions', :action => 'create', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
    assert_routing_with_host({:path => '/frontend/location_suggestions/check'}, {:controller => 'frontend/location_suggestions', :action => 'check', :namespace => nil, :subdomains => ['www']}, 'www.example.com')
  end
  
  def test_review_routes
#    # new review
#    map.new_location_review '/:state/:city/:location/reviews/new', 
#      :controller => 'frontend/reviews', :action => :new, :state => STATE_PATTERN, :via => :get
#    map.create_location_review '/:state/:city/:location/reviews', 
#      :controller => 'frontend/reviews', :action => :create, :state => STATE_PATTERN, :via => :post
#    map.confirm_review '/reviews/:id/:token', 
#      :controller => 'frontend/reviews', :action => :confirm, :via => :get
  end
  
  def test_state_routes
#    # state
#    map.state_rewrite '/:state.html', 
#      :controller => 'frontend/states', :action => :show, :state => STATE_PATTERN
  end
  
  def test_search_routes
    assert_routing_with_host({:path => '/suche.html'}, {:controller => 'frontend/searches', :action => 'search', :search_str => 'search for xyz', :namespace => nil, :subdomains => ['www']}, 'www.example.com', {}, {:search_str => 'search for xyz'})
    assert_routing_with_host({:path => '/suchvorschlaege'}, {:controller => 'frontend/searches', :action => 'suggestions', :search_str => 'search for xyz', :namespace => nil, :subdomains => ['www']}, 'www.example.com', {}, {:search_str => 'search for xyz'})
  end
end