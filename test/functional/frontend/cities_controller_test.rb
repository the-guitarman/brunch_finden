#encoding: utf-8

require 'test_helper'

class Frontend::CitiesControllerTest < ActionController::TestCase
  # process before each test method
  def setup

  end

  # process after each test method
  def teardown

  end

  def test_show_city_with_locations_by_rewrite
    c = City.first
    assert c.number_of_locations > 0
    
    get :show, create_rewrite_hash(c.rewrite)
    
    assert_response :success
    assert_template 'frontend/cities/show'

    assert_select 'head' do 
      #puts @selected
      assert_select 'title', "Brunchen Chemnitz (Sachsen) - www.example.com"
      assert_select 'meta[name=robots][content="index,follow"]', 1
    end
  end

  def test_show_city_without_locations_by_rewrite
    c = City.first
    c.number_of_locations = 0
    c.save
    assert c.number_of_locations == 0

    get :show, create_rewrite_hash(c.rewrite)
    assert_response :success
    assert_template 'frontend/cities/show'

    assert_select 'head' do 
      #puts @selected
      assert_select 'title', "Brunchen Chemnitz (Sachsen) - www.example.com"
      assert_select 'meta[name=robots][content="noindex,noarchive,follow"]', 1
    end
  end
end
