#encoding: utf-8
require 'test_helper'

class BackendUserSessionTest < ActiveSupport::TestCase
  fixtures :backend_users
  
  # process before each test method
  def setup
    activate_authlogic
  end

  # process after each test method
  def teardown

  end

  def test_01_create_and_do_not_login_after_create_and_logout
    attributes = BackendUser.last.attributes.except(:id, :password, 'id', 'password')
    attributes[:login] = 'my-new-user-login'
    attributes[:password] = 'mytest'
    attributes[:password_confirmation] = 'mytest'
    attributes[:active] = false
    BackendUser.delete_all
    
    user = BackendUser.create(attributes)
    assert user.valid?
    
    user.reload
    
    # not logged in after create
    assert !test_us_1 = BackendUserSession.find
    assert test_us_1.nil?
    
    # can not login an inactive user
    assert test_us_2 = BackendUserSession.create({:login => attributes[:login], :password => attributes[:password]})
    assert test_us_2.backend_user.nil?
    
    # login an active user
    user.active = true
    assert user.save
    assert test_us_3 = BackendUserSession.create({:login => attributes[:login], :password => attributes[:password]})
    assert_equal user, test_us_3.backend_user
    
    # logout
    test_us_3.destroy
    assert test_us_3.backend_user.nil?
    
    # login the active user again
    assert test_us_4 = BackendUserSession.create({:login => attributes[:login], :password => attributes[:password]})
    assert_equal user, test_us_4.backend_user
  end
  
  def test_02_configuration
    assert BackendUserSession.logout_on_timeout
    assert_equal :login, BackendUserSession.login_field
  end
end
