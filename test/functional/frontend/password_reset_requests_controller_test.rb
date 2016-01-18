#encoding: utf-8

require 'test_helper'

class Frontend::PasswordResetRequestsControllerTest < ActionController::TestCase
  fixtures :frontend_users

  # process before each test method
  def setup
    
  end

  # process after each test method
  def teardown

  end
  
  def test_new
    get :new
    assert_response :success
    assert_template 'frontend/password_reset_requests/new'
    
    assert_select 'head' do
      assert_select 'title', 'example.com - Passwort vergessen'
    end
    assert_select 'body' do
      assert_select 'form input[name=login_or_email]', true
    end
    
    # @current_user
    current_user = assigns(:current_user)
    assert_nil current_user
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_nil current_user_session
    
#    # xhr request
#    xhr :get, :new
#    assert_response :success
#    assert_template 'frontend/password_reset_requests/new'
#    assert_equal Mime::JS, response.content_type

    
    # redirection if logged in
    frontend_user_log_on
    
    get :new
    assert_response :redirect
    assert_redirected_to :controller => 'frontend/community/users', :action => 'account'
  end
  
  def test_create
    post :create, {}
    assert_response :success
    assert_template 'frontend/password_reset_requests/new'
    
    # @user
    user = assigns(:user)
    assert_nil user
    
    assert_select 'head' do
      assert_select 'title', 'example.com - Passwort vergessen'
    end
    assert_select 'body' do
      assert_select 'h1', 'Forgot your password?'
      assert_select 'h1 + div' do |div|
        div.find{|el| el.to_s.start_with?('<div>Sie sollten innerhalb der')}
      end
    end
    
    
    
    
    post :create, {:login_or_email => 'unknown'}
    assert_response :success
    
    # @user
    user = assigns(:user)
    assert_nil user
    
    assert_template 'frontend/password_reset_requests/create'
    assert_select 'head' do
      assert_select 'title', 'example.com - Passwort vergessen'
    end
    assert_select 'body' do
      assert_select 'h1', 'Forgot your password?'
      assert_select 'h1 + div' do |div|
        div.find{|el| el.to_s.start_with?('<div>Sie sollten innerhalb der')}
      end
    end
    
    
    
    
    user = frontend_user_for_login
    
    post :create, {:login_or_email => user.login}
    assert_response :success
    assert_template 'frontend/password_reset_requests/create'
    
    # @user
    user = assigns(:user)
    assert_not_nil user
    
    assert_select 'head' do
      assert_select 'title', 'example.com - Passwort vergessen'
    end
    assert_select 'body' do
      assert_select 'h1', 'Forgot your password?'
      assert_select 'h1 + div' do |div|
        div.find{|el| el.to_s.start_with?('<div>Sie sollten innerhalb der')}
      end
    end
    
    # @current_user
    current_user = assigns(:current_user)
    assert_nil current_user
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_nil current_user_session
    
    
    
    
    post :create, {}
    assert_response :success
    assert_template 'frontend/password_reset_requests/new'
  end
  
#  def test_create_with_xhr
#    user = frontend_user_for_login
#    
#    # xhr request
#    xhr :post, :create, :login_or_email => user.login
#    assert_response :success
#    
#    # @user
#    user = assigns(:user)
#    assert_not_nil user
#    
#    assert_equal Mime::JS, response.content_type
#    assert_template 'frontend/password_reset_requests/create'
#    assert_select 'head', false
#    assert_select 'body', false
#    assert response.body.include?('<h1>Passwort vergessen?<')
#    assert response.body.include?('Das hat geklappt')
#    
#    # redirection if logged in
#    frontend_user_log_on
#    
#    get :edit, :id => user.perishable_token
#    assert_response :redirect
#    assert_redirected_to url_for(:controller => 'frontend/community/users', :action => 'account')
#  end
  
  def test_edit
    get :edit
    assert_response :success
    assert_template 'frontend/password_reset_requests/new'
    
    # @user
    user = assigns(:user)
    assert_nil user
    
    user = frontend_user_for_login
    user.reset_perishable_token!
    get :edit, :id => user.perishable_token
    assert_response :success
    assert_template 'frontend/password_reset_requests/edit'
    
    # @user
    user = assigns(:user)
    assert_not_nil user
    
    assert_select 'head' do
      assert_select 'title', 'example.com - Neues Passwort speichern'
    end
    assert_select 'body' do
      assert_select 'form input[type=hidden][name=id]', true
      assert_select "form input[type=password][name='frontend_user[password]']", true
      assert_select "form input[type=password][name='frontend_user[password_confirmation]']", true
    end
    
    # @current_user
    current_user = assigns(:current_user)
    assert_nil current_user
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_nil current_user_session
    
    # redirection if logged in
    frontend_user_log_on
    
    get :edit, :id => user.perishable_token
    assert_response :redirect
    assert_redirected_to url_for(:controller => 'frontend/community/users', :action => 'account', :namespace => nil, :subdomains => ['www'])
  end
  
  def test_update
    put :update
    assert_response :success
    assert_template 'frontend/password_reset_requests/new'
    
    # @user
    user = assigns(:user)
    assert_nil user
    
    assert_select 'head' do
      assert_select 'title', 'example.com - Neues Passwort speichern'
    end
    
    user = frontend_user_for_login
    user.reset_perishable_token!
    put :update, :id => user.perishable_token, :frontend_user => {
      :password => 'new-password', 
      :password_confirmation => 'not-the-same-new-password', 
    }
    assert_response :success
    assert_template 'frontend/password_reset_requests/edit'
    
    # @user
    user = assigns(:user)
    assert_not_nil user
    
    assert_select 'head' do
      assert_select 'title', 'example.com - Neues Passwort speichern'
    end
    
    user = frontend_user_for_login
    user.reset_perishable_token!
    put :update, :id => user.perishable_token, :frontend_user => {
      :password => 'new-password', 
      :password_confirmation => 'new-password', 
    }
    assert_response :success
    assert_template 'frontend/password_reset_requests/update'
    
    # @user
    user = assigns(:user)
    assert_not_nil user
    
    assert_select 'head' do
      assert_select 'title', 'example.com - Neues Passwort speichern'
    end
    assert_select 'body' do
      assert_select 'h1', 'New password saved!'
      assert_select 'h1 + div' do |div|
        div.find{|el| el.to_s.start_with?('<div>Herzlichen Glückwunsch. Sie haben das Passwort')}
      end
    end
    
    # @current_user
    current_user = assigns(:current_user)
    assert_nil current_user
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_not_nil current_user_session
  end
end