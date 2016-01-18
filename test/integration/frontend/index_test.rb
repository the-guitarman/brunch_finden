require File.dirname(__FILE__) + '/../../test_helper'

class Frontend::IndexTest < ActionController::IntegrationTest
  # process before each test method
  def setup

  end

  # process after each test method
  def teardown

  end

  def test_01_root_url
    get root_url
    
    assert_response :success

    assert_template 'frontend/index/index'

    fc = CustomConfigHandler.instance.frontend_config
    assert_select 'title', "Brunch-Locations finden auf #{fc['DOMAIN']['FULL_NAME']}"
  end

  def test_02_about_us
    get about_us_url

    assert_response :success

    assert_template 'frontend/index/about_us'

    fc = CustomConfigHandler.instance.frontend_config
    assert_select 'title', "Über uns - #{fc['DOMAIN']['FULL_NAME']}"
  end

  def test_03_general_terms_and_conditions
    get general_terms_and_conditions_url

    assert_response :success

    assert_template 'frontend/index/general_terms_and_conditions'

    fc = CustomConfigHandler.instance.frontend_config
    assert_select 'title', "Allgemeine Geschäftsbedingungen - #{fc['DOMAIN']['NAME']}"
  end

  def test_04_privacy_notice
    get privacy_notice_url

    assert_response :success

    assert_template 'frontend/index/privacy_notice'

    fc = CustomConfigHandler.instance.frontend_config
    assert_select 'title', "Datenschutz - #{fc['DOMAIN']['FULL_NAME']}"
  end

  def test_05_registration_information
    get registration_information_url

    assert_response :success

    assert_template 'frontend/index/registration_information'

    fc = CustomConfigHandler.instance.frontend_config
    assert_select 'title', "Impressum - #{fc['DOMAIN']['FULL_NAME']}"
  end
end