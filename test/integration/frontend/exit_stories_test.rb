require 'test_helper'

class Frontend::ExitStoriesTest < ActionController::IntegrationTest
  include Frontend::ExitLinksHelper
  
  # process before each test method
  def setup
    
  end

  # process after each test method
  def teardown

  end

  def test_01_byebye
    remote_addr = '192.168.100.21'
    user_agent  = 'Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.2.12) Gecko/20101027 Ubuntu/10.10 (maverick) Firefox/3.6.12'
    fch = CustomConfigHandler.instance.frontend_config
    platform = fch['DOMAIN']['FULL_NAME']
    position = 100
    template = 'my_test_template'
    header_parameters = {'REMOTE_ADDR' => remote_addr, 'HTTP_USER_AGENT' => user_agent}
    
    # prepare the Time class,
    # because sessions can not be prepared before a controller call
    def Time.now; Time.new.yesterday; end
    
    Clickout.delete_all
    assert_equal 0, Clickout.count
    
    # click to the coupon (1)
    coupon_1 = Coupon.find(1)
    get coupon_exit_url(coupon_1, {:position => position, :template => template}),
      nil, header_parameters
    
    # an exit click has no template
    assert_template ''
    
    assert_equal 1, Clickout.count
    assert co = Clickout.last
    assert_equal remote_addr, co.remote_ip
    assert_equal user_agent, co.user_agent
    assert_equal co.destination, coupon_1
    assert_equal template, co.template
    assert_equal position, co.position
    assert_equal platform, co.platform

    key = coupon_1.class.name.pluralize.downcase.to_sym
    ids = session[key] ||= {}
    assert !ids.has_key?(coupon_1.id)
    #assert ids[coupon_1.id].future?

    # don't track a click to the same offer (4) again
    get coupon_exit_url(coupon_1, {:position => position, :template => template}),
      nil, header_parameters
    assert_response :success
    assert_equal 2, Clickout.count

    # track a click to another coupon (2)
    coupon_2 = Coupon.find(2)
    get coupon_exit_url(coupon_2, {:position => position, :template => template}),
      nil, header_parameters
    assert_response :success
    assert_equal 3, Clickout.count

    # prepare the Time class,
    # because sessions can not be prepared before a controller call
    def Time.now; Time.new; end

    # track a click to the first coupon (1), if session timeout of the offer is over
    get coupon_exit_url(coupon_1, {:position => position, :template => template}),
      nil, header_parameters
    assert_equal 4, Clickout.count


    # don't track a click ...
    session[key] = {}
    do_not_track_ip = Clickout.model_config('CLICKOUT', 'DO_NOT_TRACK', 'IPS').first
    do_not_track_ua = Clickout.model_config('CLICKOUT', 'DO_NOT_TRACK', 'USER_AGENTS').first

    # ... from a forbidden ip address
    get coupon_exit_url(coupon_1, {:position => position, :template => template}),
      nil, header_parameters.merge({'REMOTE_ADDR' => do_not_track_ip})
    assert_equal 4, Clickout.count

    # ... for a forbidden user agent
    get coupon_exit_url(coupon_2, {:position => position, :template => template}),
      nil, header_parameters.merge({'HTTP_USER_AGENT' => do_not_track_ua})
    assert_equal 4, Clickout.count




    # Do not destroy an object by calling destroy method,
    # which is not defined as exit attribute/method (See: Mixin::ActsAsClickoutable).
    #assert_raise(NoMethodError) do
      get get_byebye_url(coupon_1, 'destroy', {:template => template}),
        nil, header_parameters
      exit_url = assigns(:exit_url)
      assert exit_url.blank?
      #assert_response :error
    #end
  end
end
