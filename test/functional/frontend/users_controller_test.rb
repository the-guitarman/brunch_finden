#encoding: utf-8

require 'test_helper'

class Frontend::UsersControllerTest < ActionController::TestCase

  # process before each test method
  def setup
    
  end

  # process after each test method
  def teardown

  end
  
  def test_new
    get :new
    assert_response :success
    assert_template 'frontend/users/new'
    assert_select 'head' do
      assert_select 'title', 'example.com - Anmeldung'
    end
    
    # @current_user
    current_user = assigns(:current_user)
    assert_not_nil current_user
    assert current_user.new_record?
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_nil current_user_session
  end
  
  def test_create
    post :create
    assert_response :success
    assert_template 'frontend/users/new'
    
    # @current_user
    current_user = assigns(:current_user)
    assert_not_nil current_user
    assert current_user.new_record?
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_not_nil current_user_session
    assert current_user_session.new_record?
    
    post :create, {
      :frontend_user => {
        :login => 'hans_wurst', 
        :first_name => 'Hans', 
        :name  => 'Wurst', 
        :email => 'hans@wurst.de',
        :password => 'test',
        :password_confirmation => 'test',
        :general_terms_and_conditions => true
      }
    }
    current_user = assigns(:current_user)
    assert_response :redirect
    assert_redirected_to frontend_user_account_url
    
    # @current_user
    current_user = assigns(:current_user)
    assert_not_nil current_user
    assert_equal 'hans_wurst', current_user.login
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_not_nil current_user_session
    assert_equal current_user, current_user_session.frontend_user
  end
  
  def test_confirm_a_user_without_a_user_has_been_logged_in
    waiting_user = FrontendUser.find(4)
    
    get :confirm, :confirmation_code => 'wrong-code'
    assert_response :success
    assert_template 'frontend/users/confirm_now'
    assert_select 'head' do
      assert_select 'title', 'example.com - The Shopping Community, Product and Store Reviews, Online Shopping Guide, Comparison Shopping'
    end
    
    get :confirm, :confirmation_code => waiting_user.perishable_token
    assert_response :success
    assert_template 'frontend/users/confirmed'
    assert_select 'head' do
      assert_select 'title', 'example.com - The Shopping Community, Product and Store Reviews, Online Shopping Guide, Comparison Shopping'
    end
    
    # @user
    user = assigns(:user)
    assert_not_nil user
    assert_equal 4, user.id
    
    # @current_user
    current_user = assigns(:current_user)
    assert_nil current_user
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_not_nil current_user_session
  end
  
  def test_confirm_now
    get :confirm_now, :confirmation_code => 'wrong-code'
    assert_response :success
    assert_template 'frontend/users/confirm_now'
    assert_select 'head' do
      assert_select 'title', 'example.com'
    end
    
    waiting_user = FrontendUser.find(4)
    get :confirm_now, :confirmation_code => waiting_user.perishable_token
    assert_response :success
    assert_template 'frontend/users/confirmed'
    assert_select 'head' do
      assert_select 'title', 'example.com'
    end
    
    # @user
    user = assigns(:user)
    assert_not_nil user
    assert_equal 4, user.id
    
    # @current_user
    current_user = assigns(:current_user)
    assert_nil current_user
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_not_nil current_user_session
  end
  
  def test_confirm_new_user_now
    get :confirm_new_user_now, :confirmation_code => 'wrong-code'
    assert_response :success
    assert_template 'frontend/users/confirm_now'
    assert_select 'head' do
      assert_select 'title', 'example.com'
    end
    
    waiting_user = FrontendUser.find(4)
    get :confirm_new_user_now, :confirmation_code => waiting_user.perishable_token
    assert_response :success
    assert_template 'frontend/users/confirmed'
    assert_select 'head' do
      assert_select 'title', 'example.com'
    end
    
    # @user
    user = assigns(:user)
    assert_not_nil user
    assert_equal 4, user.id
    
    # @current_user
    current_user = assigns(:current_user)
    assert_nil current_user
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_not_nil current_user_session
  end
  
  def test_confirm_new_user_now_with_xhr
    fu = FrontendUser.find(4)
    
    frontend_user_log_on(fu)
    
    xhr :get, :confirm_new_user_now
    assert_response :success
    assert_template 'frontend/users/confirm_now'
    assert_select 'head', false
    assert_select 'title', false

    #assert response.body.include?("Vielen Dank für Ihre Anmeldung!")
    
    #xhr :post, :confirm_new_user_now
    #assert response.body.include?('The Activation code is invalid.')
    
    #xhr :post, :confirm_new_user_now, :confirmation_code => 'wrong-code'
    #assert response.body.include?('The Activation code is invalid.')
    
    
    #xhr :post, :confirm_new_user_now, :confirmation_code => fu.perishable_token
    #assert !response.body.include?('The Activation code is invalid.')
    #assert response.body.include?('Your account is confirmed now.')
  end
  
  def test_confirm_later
    get :confirm_later
    assert_response :redirect
    assert_redirected_to frontend_user_login_url
    
    frontend_user_log_on
    
    get :confirm_later
    assert_response :redirect
    assert_redirected_to frontend_user_account_url
  end
  
  # confirm new email via opt-in
  def test_confirm_new_email
    get :confirm_new_email, :confirmation_code => 'wrong-code'
    assert_response :success
    assert_template 'frontend/users/new_email_confirm_now'
    assert_select 'head' do
      assert_select 'title', 'example.com'
    end
    
    # @user
    user = assigns(:user)
    assert_nil user
    
    
    new_email = 'test@lvh.me'
    fu = FrontendUser.first
    fu.new_email = new_email
    assert fu.save
    
    get :confirm_new_email, :confirmation_code => fu.perishable_token
    assert_response :success
    assert_template 'frontend/users/new_email_confirmed'
    assert_select 'head' do
      assert_select 'title', 'example.com'
    end
    
    # @user
    user = assigns(:user)
    assert_not_nil user
    assert_equal fu.id, user.id
    assert_equal new_email, user.email
    assert user.read_attribute(:new_email).blank?
    
    # @current_user
    current_user = assigns(:current_user)
    assert_nil current_user
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_not_nil current_user_session
  end
  
  # confirm new email via standard formular
  def test_confirm_new_email_now
    get :confirm_new_email_now
    assert_response :success
    assert_template 'frontend/users/new_email_confirm_now'
    assert_select 'head' do
      assert_select 'title', 'example.com'
    end
    
    # @user
    user = assigns(:user)
    assert_nil user
    
    
    
    
    post :confirm_new_email_now
    assert_response :success
    assert_template 'frontend/users/new_email_confirm_now'
    assert_select 'head' do
      assert_select 'title', 'example.com'
    end
    
    # @user
    user = assigns(:user)
    assert_nil user
    
    
    
    
    post :confirm_new_email_now, :confirmation_code => 'wrong-code'
    assert_response :success
    assert_template 'frontend/users/new_email_confirm_now'
    assert_select 'head' do
      assert_select 'title', 'example.com'
    end
    
    # @user
    user = assigns(:user)
    assert_nil user
    
    
    
    new_email = 'test@lvh.me'
    fu = FrontendUser.first
    fu.new_email = new_email
    assert fu.save
    
    post :confirm_new_email_now, :confirmation_code => fu.perishable_token
    assert_response :success
    assert_template 'frontend/users/new_email_confirmed'
    assert_select 'head' do
      assert_select 'title', 'example.com'
    end
    
    # @user
    user = assigns(:user)
    assert_not_nil user
    assert_equal fu.id, user.id
    assert_equal new_email, user.email
    assert user.read_attribute(:new_email).blank?
    
    # @current_user
    current_user = assigns(:current_user)
    assert_nil current_user
    
    # @current_user_session
    current_user_session = assigns(:current_user_session)
    assert_not_nil current_user_session
  end
end
