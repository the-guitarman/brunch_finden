#encoding: utf-8
require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  # process before each test method
  def setup

  end

  # process after each test method
  def teardown

  end

  def test_01_create
    LocationSuggestion.delete_all
    ActionMailer::Base.deliveries = []

    test_l1 = LocationSuggestion.create
    assert !test_l1.valid?
    assert test_l1.errors.invalid?(:name)
    assert test_l1.errors.invalid?(:city)
    
    assert ActionMailer::Base.deliveries.empty?

    l1 = LocationSuggestion.create({:name => 'Alex', :city => 'Chemnitz'})
    assert l1.valid?
    assert !l1.errors.invalid?(:name)
    assert !l1.errors.invalid?(:city)
    
    assert_equal 1, ActionMailer::Base.deliveries.length
    tmail = ActionMailer::Base.deliveries.first
    assert_equal 'text/plain', tmail.content_type
    assert_equal I18n.translate('mailers.frontend.location_suggestion_mailer.location_suggestion.subject', {
      :domain_name => get_domain_name}), tmail.subject
  end

  def get_domain_name
    fec = CustomConfigHandler.instance.frontend_config
    return fec['DOMAIN']['NAME'].downcase
  end
end