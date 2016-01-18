#encoding: utf-8
require 'test_helper'

class PageHeaderTagConfiguratorTest < ActiveSupport::TestCase
  class ControllerMock
    attr_accessor :controller_name, :action_name, :logged_in, :page
    def logged_in?
      @logged_in
    end
    
    def params
      {}
    end
    
    def mobile_device?
      false
    end
  end
  
  class Frontend::ControllerMock < ControllerMock
    def initialize
      fec = CustomConfigHandler.instance.frontend_config
      @host_full_name = fec['DOMAIN']['FULL_NAME']
#      case type
#      when :frontend
#        @host_full_name = fec['DOMAIN']['FULL_NAME']
#      when :backend
#        @host_full_name = fec['BACKEND']['DOMAIN']
#      end
    end
  end
  
  # process before each test method
  def setup
    
  end

  # process after each test method
  def teardown

  end

  def test_01_standard_header
    # This returns the standard page header tags defined for a controller - action 
    # combination. All standard text variables like domain names are replaced at this moment.
    phtc = PageHeaderTagConfigurator.new(get_frontend_controller_mock('index', 'index', false))
    phts = phtc.page_header_tags
    
    assert phts.is_a?(Hash)
    assert phts.key?('title')
    assert phts['title'].is_a?(String)
    assert_equal 'Brunch-Locations finden auf www.example.com', phts['title']
    
    assert phts.key?('meta')
    assert phts['meta'].is_a?(Hash)
    assert phts['meta'].key?('keywords')
    assert_equal 'brunchvergleich,brunch,location,locations,brunch location,brunch locations,restaurant,restaurants,frühstück,mittag,essen,finden,suchen,vergleichen,bewerten', 
      phts['meta']['keywords']
    assert phts['meta'].key?('description')
    assert_equal 'Brunchvergleich und Meinungen zu über 0 Brunch Locations und Restaurants in deiner Nähe.', 
      phts['meta']['description']
    assert phts['meta'].key?('robots')
    assert_equal 'index,follow', phts['meta']['robots']
  end

  def test_02_state_header
    # This returns the state page header tags. All standard text variables 
    # like domain names are replaced at this moment.
    phtc = PageHeaderTagConfigurator.new(get_frontend_controller_mock('states', 'show', false))
    phts = phtc.page_header_tags
    
    assert phts.is_a?(Hash)
    assert phts.key?('title')
    assert phts['title'].is_a?(String)
    assert_equal 'Brunch Locations in __STATE_NAME__ finden - www.example.com', phts['title']
    
    assert phts.key?('meta')
    assert phts['meta'].is_a?(Hash)
    assert phts['meta'].key?('keywords')
    assert_equal 'brunch,finden,__STATE_NAME__,example.com', 
      phts['meta']['keywords']
    assert phts['meta'].key?('description')
    assert_equal 'Brunchen in __STATE_NAME__ - Finde Brunch-Locations in __STATE_NAME__. Genieße dein Leben und gehe doch mal in __STATE_NAME__ brunchen.', 
      phts['meta']['description']
    assert phts['meta'].key?('robots')
    assert_equal 'index,follow', phts['meta']['robots']
    
    
    
    # Now set the state and replace the state text variables in the former result.
    state = State.first
    phts = phtc.set_state(state)
    
    assert phts.is_a?(Hash)
    assert phts.key?('title')
    assert phts['title'].is_a?(String)
    assert_equal 'Brunch Locations in Sachsen finden - www.example.com', phts['title']
    
    assert phts.key?('meta')
    assert phts['meta'].is_a?(Hash)
    assert phts['meta'].key?('keywords')
    assert_equal 'brunch,finden,Sachsen,example.com', 
      phts['meta']['keywords']
    assert phts['meta'].key?('description')
    assert_equal "Brunchen in Sachsen - Finde Brunch-Locations in Sachsen. Genieße dein Leben und gehe doch mal in Sachsen brunchen.", 
      phts['meta']['description']
    assert phts['meta'].key?('robots')
    assert_equal 'index,follow', phts['meta']['robots']
  end
  
  def test_03_city_header
    # This returns the city page header tags. All standard text variables 
    # like domain names are replaced at this moment.
    phtc = PageHeaderTagConfigurator.new(get_frontend_controller_mock('cities', 'show', false))
    phts = phtc.page_header_tags
    
    assert phts.is_a?(Hash)
    assert phts.key?('title')
    assert phts['title'].is_a?(String)
    assert_equal 'Brunchen __CITY_NAME__ (__STATE_NAME__) - www.example.com', phts['title']
    
    assert phts.key?('meta')
    assert phts['meta'].is_a?(Hash)
    assert phts['meta'].key?('keywords')
    assert_equal 'brunch,finden,__CITY_NAME__,__STATE_NAME__,example.com', 
      phts['meta']['keywords']
    assert phts['meta'].key?('description')
    assert_equal 'Brunchen in __CITY_NAME__ (__STATE_NAME__) - Wähle unter __NUMBER_OF_LOCATIONS_WITH_MODEL__ und finde den passenden Brunch für jede Gelegenheit. Jetzt Locations von __CITY_NAME__ (__STATE_NAME__) anschauen.', 
      phts['meta']['description']
    assert phts['meta'].key?('robots')
    assert_equal 'index,follow', phts['meta']['robots']
    
    
    
    # Now set the city and replace the state and city text variables in the former result.
    city = City.first
    phts = phtc.set_city(city)
    
    assert phts.is_a?(Hash)
    assert phts.key?('title')
    assert phts['title'].is_a?(String)
    assert_equal 'Brunchen Chemnitz (Sachsen) - www.example.com', phts['title']
    
    assert phts.key?('meta')
    assert phts['meta'].is_a?(Hash)
    assert phts['meta'].key?('keywords')
    assert_equal 'brunch,finden,Chemnitz,Sachsen,example.com', 
      phts['meta']['keywords']
    assert phts['meta'].key?('description')
    assert_equal "Brunchen in Chemnitz (Sachsen) - Wähle unter 1 Brunch-Location und finde den passenden Brunch für jede Gelegenheit. Jetzt Locations von Chemnitz (Sachsen) anschauen.", 
      phts['meta']['description']
    assert phts['meta'].key?('robots')
    assert_equal 'index,follow', phts['meta']['robots']
  end
  
  def test_04_location_header
    # This returns the lacation page header tags. All standard text variables 
    # like domain names are replaced at this moment.
    phtc = PageHeaderTagConfigurator.new(get_frontend_controller_mock('locations', 'show', false))
    phts = phtc.page_header_tags
    
    assert phts.is_a?(Hash)
    assert phts.key?('title')
    assert phts['title'].is_a?(String)
    assert_equal '__LOCATION_NAME__ (__STATE_NAME__) - www.example.com', phts['title']
    
    assert phts.key?('meta')
    assert phts['meta'].is_a?(Hash)
    assert phts['meta'].key?('keywords')
    assert_equal 'brunch,location,__LOCATION_NAME__,__STATE_NAME__,example.com', 
      phts['meta']['keywords']
    assert phts['meta'].key?('description')
    assert_equal 'Details zur Brunch-Location __LOCATION_NAME__ (__STATE_NAME__) auf www.example.com. Erfahre den Preis, die Öffnungszeiten und vieles mehr ...', 
      phts['meta']['description']
    assert phts['meta'].key?('robots')
    assert_equal 'index,follow', phts['meta']['robots']
    
    
    
    # Now set the city and replace the state, city and location text variables in the former result.
    location = Location.first
    phts = phtc.set_location(location)
    
    assert phts.is_a?(Hash)
    assert phts.key?('title')
    assert phts['title'].is_a?(String)
    assert_equal 'ALEX Chemnitz (Sachsen) - www.example.com', phts['title']
    
    assert phts.key?('meta')
    assert phts['meta'].is_a?(Hash)
    assert phts['meta'].key?('keywords')
    assert_equal 'brunch,location,ALEX Chemnitz,Sachsen,example.com', 
      phts['meta']['keywords']
    assert phts['meta'].key?('description')
    assert_equal "Details zur Brunch-Location ALEX Chemnitz (Sachsen) auf www.example.com. Erfahre den Preis, die Öffnungszeiten und vieles mehr ...", 
      phts['meta']['description']
    assert phts['meta'].key?('robots')
    assert_equal 'index,follow', phts['meta']['robots']
  end
  
  private
  
  def get_controller_mock(controller_mock, controller_name, action_name, logged_in)
    controller_mock.controller_name = controller_name
    controller_mock.action_name = action_name
    controller_mock.logged_in = logged_in
    return controller_mock
  end
  
  def get_frontend_controller_mock(controller_name, action_name, logged_in)
    return get_controller_mock(Frontend::ControllerMock.new, controller_name, action_name, logged_in)
  end
  
  def get_customer_backend_controller_mock(controller_name, action_name, logged_in)
    return get_controller_mock(CustomerBackend::ControllerMock.new, controller_name, action_name, logged_in)
  end
end