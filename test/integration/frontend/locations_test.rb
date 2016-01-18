require File.dirname(__FILE__) + '/../../test_helper'

class Frontend::LocationsTest < ActionController::IntegrationTest  
  # process before each test method
  def setup
    
  end

  # process after each test method
  def teardown
    
  end

  def test_new_location
    # via named url
    get new_location_url

    assert_response :success

    assert_template 'frontend/locations/new'

    fc = CustomConfigHandler.instance.frontend_config
    assert_select 'title', "Neue Brunch Location anlegen - #{fc['DOMAIN']['FULL_NAME']}"
    
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
    
  def test_create_location_from_new_user
    Location.delete_all
    assert_equal 0, Location.count
    ActionMailer::Base.deliveries = []
    
    post frontend_locations_url, {
      :location => {
        :zip_code_id => 1,
        :name        => 'Cafe Moskau',
        :description => '',
        :street      => 'Straße der Nationen 56',
        :email       => 'axel.schweiss@cafe-moskau.de',
        :phone       => '0371 9837433',
        :price       => 6.5,
        :general_terms_and_conditions_confirmed => true
      },
      :frontend_user => {
        :name  => 'Ede Petete',
        :email => 'ede@petete.de'
      }
    }
    assert_response :success
    assert_template 'frontend/locations/create'
    
    frontend_user = assigns(:frontend_user)
    assert_equal 'Ede Petete', frontend_user.name
    
    location = assigns(:location)
    assert_equal frontend_user.id, location.frontend_user_id
    assert_equal 'Cafe Moskau', location.name
    assert !location.published 
    
    assert_equal 1, Location.count
    assert_equal 1, ActionMailer::Base.deliveries.length
  end
  
  def test_create_location_from_existing_user
    Location.delete_all
    assert_equal 0, Location.count
    ActionMailer::Base.deliveries = []
    
    fu = FrontendUser.last
    post frontend_locations_url, {
      :location => {
        :zip_code_id => 1,
        :name        => 'Cafe Moskau',
        :description => '',
        :street      => 'Straße der Nationen 56',
        :email       => 'axel.schweiss@cafe-moskau.de',
        :phone       => '0371 9837433',
        :price       => 6.5,
        :general_terms_and_conditions_confirmed => true
      },
      :frontend_user => {
        :name  => fu.name,
        :email => fu.email
      }
    }
    assert_response :success
    assert_template 'frontend/locations/create'
    
    frontend_user = assigns(:frontend_user)
    assert_equal fu, frontend_user
    
    location = assigns(:location)
    assert_equal frontend_user.id, location.frontend_user_id
    assert_equal 'Cafe Moskau', location.name
    assert !location.published 
    
    assert_equal 1, Location.count
    assert_equal 1, ActionMailer::Base.deliveries.length
  end
  
  def test_location_confirmation
    begin
      # force the controller to be reloaded when caching is enabled
      ActionController::Base.perform_caching = true
      load "frontend/locations_controller.rb"
      
      l = Location.last
      
      path_1 = root_path
      path_2 = location_rewrite_path(create_rewrite_hash(l.rewrite))
      
      get root_path
      
      #create_page_cache(path_1)
      page_cache_exists?(path_1)
      
      l.published = false
      assert l.save
      
      page_cache_not_exists?(path_1)
      
      create_page_cache(path_2)
      page_cache_exists?(path_2)

      get confirm_frontend_location_url({:id => l.id, :token => l.confirmation_code})
      assert_response :success
      assert_template 'frontend/locations/confirm'

      location = assigns(:location)
      assert_equal l, location
      assert location.published
      
      page_cache_not_exists?(path_1)
      page_cache_not_exists?(path_2)
    ensure
      # undo the actions above
      ActionController::Base.perform_caching = false
      load "frontend/locations_controller.rb"

      delete_page_cache(path_1)
      delete_page_cache(path_2)
    end
  end

  def test_show_location_by_rewrite
    l = Location.first
    get location_rewrite_url(create_rewrite_hash(l.rewrite))

    assert_response :success

    assert_template 'frontend/locations/show'

    fc = CustomConfigHandler.instance.frontend_config
    assert_select 'title', "#{l.name} (#{l.zip_code.city.state.name}) - #{fc['DOMAIN']['FULL_NAME']}"
  end

  def test_create_page_cache
    begin
      # force the controller to be reloaded when caching is enabled
      ActionController::Base.perform_caching = true
      load "frontend/locations_controller.rb"

      l = Location.first
      
      path = location_rewrite_path(create_rewrite_hash(l.rewrite))
      
      delete_page_cache(path)
      
      page_cache_not_exists?(path)
      get path
      assert_response :success
      page_cache_exists?(path)
      
      l.description = 'new description'
      assert l.save
      page_cache_not_exists?(path)
      
      get path
      assert_response :success
      page_cache_exists?(path)
    ensure
      # undo the actions above
      ActionController::Base.perform_caching = false
      load "frontend/locations_controller.rb"

      delete_page_cache(path)
    end
  end
end