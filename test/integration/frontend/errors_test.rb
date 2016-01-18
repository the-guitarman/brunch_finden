require File.dirname(__FILE__) + '/../../test_helper'

class Frontend::ErrorsTest < ActionController::IntegrationTest
  # process before each test method
  def setup
        
  end

  # process after each test method
  def teardown
    
  end

  def test_state_not_found
    get '/this-page-do-not-exist.html'
#    assert_response :missing
    assert_template 'frontend/errors/404'

#    fc = CustomConfigHandler.instance.frontend_config
    assert_select 'title', "Sorry, page not found.", 1
    assert_select 'meta' do 
      assert_select '[name=description][content=""]', 1
      assert_select '[name=keywords][content=""]', 1
      assert_select '[name=robots][content="noindex, noarchive, nofollow"]', 1
    end
  end
end