#ActionMailer::Base.deliveries = []
#encoding: utf-8

require 'test_helper'

class Frontend::LocationsControllerTest < ActionController::TestCase
  fixtures :locations

  # process before each test method
  def setup
    
  end

  # process after each test method
  def teardown

  end
  
  def test_create
    Location.delete_all
    assert_equal 0, Location.count
    ActionMailer::Base.deliveries = []
    
    post :create, valid_location_attributes
    
    assert_equal 1, Location.count
    assert_equal 1, ActionMailer::Base.deliveries.count
    tmail = ActionMailer::Base.deliveries.last
    location = assigns(:location)
    assert tmail.to.include?(location.frontend_user.email)
    assert_equal 'text/plain', tmail.content_type
    assert_equal I18n.translate('mailers.frontend.location_mailer.confirm_location.subject', {:domain_name => 'example.com'}),
      tmail.subject
  end

  private

  def valid_location_attributes(add_attributes={})
    fu = FrontendUser.last
    {
      :frontend_user => {:name => fu.name, :email => fu.email},
      :location => {
        :zip_code_id => 1,
        :name        => 'Cafe Moskau',
        :description => '',
        :street      => 'Straße der Nationen 56',
        :email       => 'axel.schweiss@cafe-moskau.de',
        :phone       => '0371 9837433',
        :price       => 6.5,
        :general_terms_and_conditions_confirmed => true
      }
    }.merge(add_attributes)
  end
end