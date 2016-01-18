require File.dirname(__FILE__) + '/../../test_helper'

class Frontend::CitiesTest < ActionController::IntegrationTest
  # process before each test method
  def setup

  end

  # process after each test method
  def teardown

  end

  def test_show_city_by_rewrite
    c = City.first
    get city_rewrite_url(create_rewrite_hash(c.rewrite))

    assert_response :success

    assert_template 'frontend/cities/show'

    fc = CustomConfigHandler.instance.frontend_config
    assert_select 'title', "Brunchen #{c.name} (#{c.state.name}) - #{fc['DOMAIN']['FULL_NAME']}"
  end
  
  def test_action_cache
    begin
      # force the controller to be reloaded when caching is enabled
      ActionController::Base.perform_caching = true
      load "frontend/cities_controller.rb"
      
      city = City.first

      path = city_rewrite_cache_key(city.rewrite)
      
      delete_action_cache(path)
      
      action_cache_does_not_exist?(path)
      
      get path
      
      action_cache_exist?(path)
      
      city.updated_at = DateTime.now
      assert city.save
      
      action_cache_does_not_exist?(path)
    ensure
      # undo the actions above
      ActionController::Base.perform_caching = false
      load "frontend/cities_controller.rb"

      delete_action_cache(path)
    end
  end
end