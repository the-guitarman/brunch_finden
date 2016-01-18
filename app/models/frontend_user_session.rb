class FrontendUserSession < Authlogic::Session::Base  
  include Mixins::PerishableTokenKeeper
  
  find_by_login_method :find_by_username_or_email
  
  # Note that 'logout_on_timeout true' will switch off the remember_me 
  # functionality. logout_on_timeout defaults to false.
  logout_on_timeout true
  
  allow_http_basic_auth false

  before_validation :validate_magic_states
  
#  # Authlogic allows a user to be logged in many times from different computers,
#  # and so users could sharing their accounts. To prevent that,
#  # we need to reset the persistence token every time a user logs in or logs out.
#  before_destroy :reset_persistence_token
#  before_create  :reset_persistence_token
#  def reset_persistence_token
#    record.reset_persistence_token
#  end
  
  # specify configuration here, such as:
  # logout_on_timeout true
  # ...many more options in the documentation

  # Log in with any of the following. Create a FrontendUserSessionsController and use it just like your other models:
  #  FrontendUserSession.create(:login => "bjohnson", :password => "my password", :remember_me => true)
  #  session = FrontendUserSession.new(:login => "bjohnson", :password => "my password", :remember_me => true); session.save
  #  FrontendUserSession.create(:openid_identifier => "identifier", :remember_me => true) # requires the authlogic-oid "add on" gem
  #  FrontendUserSession.create(my_user_object, true) # skip authentication and log the user in directly, the true means "remember me"

  # logout
  #  session.destroy

  # find session, After a session has been created, you can persist it across requests.
  # Thus keeping the user logged in:
  #  session = FrontendUserSession.find

  def remember_me_for
    10.years
  end

  def destroyed?
    record.nil?
  end
  
  def self.primary_key
    :object_id
  end
end
