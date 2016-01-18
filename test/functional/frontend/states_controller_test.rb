#encoding: utf-8

require 'test_helper'

class Frontend::StatesControllerTest < ActionController::TestCase
  # process before each test method
  def setup

  end

  # process after each test method
  def teardown

  end

  def test_show_state_by_rewrite_redirection
    s = State.first
    get :show, {:state => s.rewrite}
    
    assert_response :redirect
    assert_redirected_to({:controller => 'frontend/states', :action => 'show', :state => s.rewrite, city_char_parameter => 'C'})
  end

  def test_show_state_by_rewrite
    s = State.first

    get :show, {:controller => 'frontend/states', :action => 'show', :state => s.rewrite, city_char_parameter => 'C'}
    assert_response :success

    #assert_template 'frontend/states/show'

    assert_select 'title', "Brunch Locations in Sachsen (Cities beginning with C) finden - www.example.com"
  end
end
