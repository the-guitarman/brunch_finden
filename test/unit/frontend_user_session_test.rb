require 'test_helper'

class FrontendUserSessionTest < ActiveSupport::TestCase
  # process before each test method
  def setup
    # Activates authlogic so that you can use it in your tests.
    activate_authlogic
  end

  # process after each test method
  def teardown

  end

  def test_create_and_login_after_create_and_logout
    user = FrontendUser.new(valid_attributes)
    assert user.save

    # logged in after create by create action
    assert test_us_1 = FrontendUserSession.create(user, true)
    assert_equal user, test_us_1.frontend_user

    # logout
    test_us_1.destroy
    assert test_us_1.frontend_user.nil?

    # login a waiting user (waiting for confirmation)
    assert user.waiting?
    assert test_us_2 = FrontendUserSession.create({:login => user.login, :password => 'test'})
    test_us_2.destroy

    # login a confirmed user
    user.confirm!
    assert user.confirmed?
    assert test_us_3 = FrontendUserSession.create({:login => user.login, :password => 'test'})
    test_us_3.destroy

    # login a blocked user not allowed
    user.block!
    assert user.blocked?
    test_us_4 = FrontendUserSession.create({:login => user.login, :password => 'test'})
    assert test_us_4.frontend_user.nil?

    # login the confirmed user again
    user.confirm!
    assert user.confirmed?
    assert test_us_5 = FrontendUserSession.create({:login => user.login, :password => 'test'})
    test_us_5.destroy

    # login the confirmed user again
    assert test_us_6 = FrontendUserSession.create({:login => user.email, :password => 'test'})
    test_us_6.destroy
  end

  def test_configuration
    assert FrontendUserSession.logout_on_timeout
    assert_equal :login, FrontendUserSession.login_field
  end
  
  def test_do_not_change_perishable_token
    assert FrontendUser.included_modules.include?(Mixins::PerishableTokenKeeper)
    
    user = FrontendUser.new(valid_attributes)
    assert user.save
    
    assert user.waiting?
    token = user.perishable_token
    assert us = FrontendUserSession.create(user, true)
    assert_equal user, us.frontend_user
    assert_equal token, user.perishable_token
    us.destroy
    
    user.confirm!
    assert user.confirmed?
    assert us = FrontendUserSession.create(user, true)
    assert_equal user, us.frontend_user
    assert_not_equal token, user.perishable_token
    us.destroy
    
    token = user.perishable_token
    
    user.change_email!
    assert user.changing_email?
    assert us = FrontendUserSession.create(user, true)
    assert_equal user, us.frontend_user
    assert_equal token, user.perishable_token
    us.destroy
    
    user.confirm!
    assert user.confirmed?
    token = user.perishable_token
    user.keep_perishable_token = true
    assert us = FrontendUserSession.create(user, true)
    assert_equal user, us.frontend_user
    assert_equal token, user.perishable_token
    us.destroy
  end
  
  private

  def valid_attributes(add_attributes={})
    {
      :login => "test",
      :password => "test",
      :password_confirmation => "test",
      :email => "test@test.de",
      :first_name => 'test',
      :name => 'test',
      :general_terms_and_conditions => true
    }.merge(add_attributes)
  end
end
