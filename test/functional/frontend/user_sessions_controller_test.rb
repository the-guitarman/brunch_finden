#encoding: utf-8

require 'test_helper'

class Frontend::UserSessionsControllerTest < ActionController::TestCase
  # process before each test method
  def setup
    :activate_authlogic
  end

  # process after each test method
  def teardown

  end
  
  def test_new
    get :new
    assert_response :success
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_not_nil current_user_session
    assert current_user_session.new_record?
    assert_template 'frontend/user_sessions/new'
    assert_select 'head' do
      assert_select 'title', 'example.com - Login'
    end
  end
  
  def test_create
    post :create
    assert_response :success
    assert_template 'frontend/user_sessions/new'
    
    # @current_user
    current_user = assigns(:current_user)
    assert_nil current_user
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_not_nil current_user_session
    assert current_user_session.new_record?
    
    fu = frontend_user_for_login
    
    post :create, {
      :frontend_user_session => {
        :login => fu.login, 
        :password => "#{fu.first_name.downcase}s-password"
      }
    }
    assert_response :redirect
    assert_redirected_to :controller => 'frontend/community/users', :action => 'account'
    
    # @current_user
    current_user = assigns(:current_user)
    assert_not_nil current_user
    assert_equal fu.login, current_user.login
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_not_nil current_user_session
    assert_equal current_user, current_user_session.frontend_user
  end
  
  def test_destroy
    delete :destroy
    assert_response :redirect
    assert_redirected_to frontend_user_login_url
    
    # @current_user
    current_user = assigns(:current_user)
    assert_nil current_user
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_nil current_user_session
    
    @current_user = frontend_user_for_login
    @current_user_session = FrontendUserSession.create(@current_user, true)
    
    delete :destroy
    assert_response :success
    assert_template 'frontend/user_sessions/new'
    
    # @current_user
    current_user = assigns(:current_user)
    assert_not_nil current_user
    assert current_user.new_record?
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_not_nil current_user_session
    assert current_user_session.new_record?
  end
end
