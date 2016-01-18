require File.dirname(__FILE__) + '/../../test_helper'

class Frontend::SwitchToMobileTest < ActionController::IntegrationTest  
  def test_show_location_and_switch_to_mobile
    remote_addr = '192.168.100.21'
    user_agent  = 'Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.2.12) Gecko/20101027 Ubuntu/10.10 (maverick) Firefox/3.6.12'
    header_parameters = {'REMOTE_ADDR' => remote_addr, 'HTTP_USER_AGENT' => user_agent}
    
    l = Location.first
    
    get location_rewrite_url(create_rewrite_hash(l.rewrite)), nil, header_parameters
    assert_response :success
    
    user_agent  = 'Mozilla/5.0 (Android) Firefox/3.6.12'
    header_parameters = {'REMOTE_ADDR' => remote_addr, 'HTTP_USER_AGENT' => user_agent}
    get location_rewrite_url(create_rewrite_hash(l.rewrite)), nil, header_parameters
    assert_response :redirect
    assert_redirected_to mobile_location_rewrite_url(create_rewrite_hash(l.rewrite))
  end
end