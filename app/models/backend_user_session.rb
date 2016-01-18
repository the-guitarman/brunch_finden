class BackendUserSession < Authlogic::Session::Base
  logout_on_timeout true # default if false
  allow_http_basic_auth false

  #before_validation :validate_magic_states

  # specify configuration here, such as:
  # logout_on_timeout true
  # ...many more options in the documentation

  # Log in with any of the following. Create a BackendUserSessionsController and use it just like your other models:
  #  BackendUserSession.create(:login => "bjohnson", :password => "my password", :remember_me => true)
  #  session = BackendUserSession.new(:login => "bjohnson", :password => "my password", :remember_me => true); session.save
  #  BackendUserSession.create(:openid_identifier => "identifier", :remember_me => true) # requires the authlogic-oid "add on" gem
  #  BackendUserSession.create(my_user_object, true) # skip authentication and log the user in directly, the true means "remember me"

  # logout
  #  session.destroy

  # find session, After a session has been created, you can persist it across requests.
  # Thus keeping the user logged in:
  #  session = BackendUserSession.find
end
