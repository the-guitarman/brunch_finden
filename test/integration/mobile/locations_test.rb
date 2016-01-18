require File.dirname(__FILE__) + '/../../test_helper'

class Mobile::LocationsTest < ActionController::IntegrationTest  
  # process before each test method
  def setup
    
  end

  # process after each test method
  def teardown
    
  end

  def test_show_location_by_rewrite
    l = Location.first
    get mobile_location_rewrite_url(create_rewrite_hash(l.rewrite))

    assert_response :success

    assert_template 'mobile/locations/show'

    fc = CustomConfigHandler.instance.frontend_config
    assert_select 'title', "#{l.name} (#{l.zip_code.city.state.name}) - #{fc['DOMAIN']['FULL_NAME']}"
  end

  def test_create_page_cache
    begin
      # force the controller to be reloaded when caching is enabled
      ActionController::Base.perform_caching = true
      load "mobile/locations_controller.rb"

      l = Location.first
      
      url = mobile_location_rewrite_path(create_rewrite_hash(l.rewrite))
      
      path = URI.parse(url).path
      
      delete_page_cache(path)
      
      page_cache_not_exists?(path)
      get url
      assert_response :success
      page_cache_exists?(path)
      
      l.description = 'new description'
      assert l.save
      page_cache_not_exists?(path)
      
      get url
      assert_response :success
      page_cache_exists?(path)
    ensure
      # undo the actions above
      ActionController::Base.perform_caching = false
      load "mobile/locations_controller.rb"

      delete_page_cache(path)
    end
  end
end