require File.dirname(__FILE__) + '/../../test_helper'

require 'unit/helper/state_cache_test_helper'

class Frontend::StatesTest < ActionController::IntegrationTest
  include StateCacheTestHelper
  
  # process before each test method
  def setup

  end

  # process after each test method
  def teardown

  end
  
  def test_action_cache
    begin
      # force the controller to be reloaded when caching is enabled
      ActionController::Base.perform_caching = true
      load "frontend/states_controller.rb"
      
      state = State.first

      path = state_rewrite_cache_key_with_start_char(state.rewrite, {
        city_char_parameter => state.city_chars.last.start_char.upcase
      })
      
      delete_action_cache(path)
      
      action_cache_does_not_exist?(path)
      
      get path
      
      action_cache_exist?(path)
      
      state.updated_at = DateTime.now
      assert state.save
      
      action_cache_does_not_exist?(path)
    ensure
      # undo the actions above
      ActionController::Base.perform_caching = false
      load "frontend/states_controller.rb"

      delete_action_cache(path)
    end
  end

  def test_show_state_by_rewrite_redirection
    s = State.first
    get state_rewrite_url(create_rewrite_hash(s.rewrite))
    
    assert_response :redirect
    assert_redirected_to state_rewrite_url(create_rewrite_hash(s.rewrite).merge({city_char_parameter => 'C'}))
  end

  def test_show_state_by_rewrite
    s = State.first

    get state_rewrite_url(create_rewrite_hash(s.rewrite).merge({city_char_parameter => 'C'}))
    assert_response :success

    #assert_template 'frontend/states/show'

    assert_select 'title', "Brunch Locations in Sachsen (Cities beginning with C) finden - www.example.com"
  end
end