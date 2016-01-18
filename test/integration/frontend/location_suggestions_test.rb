require File.dirname(__FILE__) + '/../../test_helper'

class Frontend::LocationSuggestionsTest < ActionController::IntegrationTest
  # process before each test method
  def setup
    
  end

  # process after each test method
  def teardown
    
  end

  def test_01_new_location
    get new_location_suggestion_url

    assert_response :success

    assert_template 'frontend/location_suggestions/new'

    fc = CustomConfigHandler.instance.frontend_config
    assert_select 'title', "Neuer Brunch Location Vorschlag - #{fc['DOMAIN']['FULL_NAME']}"
    
#    assert_select 'head > title', "#{p.full_name} - product page at lvh.me"
#    assert_select "head > meta" do
#      assert_select "[name=description][content=" +
#        "#{p.full_name} from &amp;amp;pound;&amp;amp;nbsp;0.00 " +
#        "(#{Time.now.strftime('%d/%m/%Y')}) at lvh.me" +
#      "]"
#      assert_select "[name=keywords][content=#{p.full_name}, #{p.category.name}]"
#      assert_select "[name=robots][content=index, follow]"
#    end
  end
end