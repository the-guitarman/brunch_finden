fec = CustomConfigHandler.instance.frontend_config

ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"
  
  STATE_PATTERN = Rails.env.test? ? /.*/ : /#{State.all.map{|s| s.rewrite}.join('|')}/i
  
  if mobile_subdomain = fec['SUBDOMAINS']['MOBILE']
    map.subdomain(mobile_subdomain.to_sym, {:name => :mobile, :namespace => nil}) do |mobile|
      mobile.search '/suche.html', :controller => 'mobile/searches', :action => :search
      
      mobile.general_terms_and_conditions "/#{I18n.t('shared.routes.general_terms_and_conditions')}.html", :controller => 'mobile/index', :action => :general_terms_and_conditions
      mobile.privacy_notice "/#{I18n.t('shared.routes.privacy_notice')}.html", :controller => 'mobile/index', :action => :privacy_notice
      mobile.registration_information "/#{I18n.t('shared.routes.registration_information')}.html", :controller => 'mobile/index', :action => :registration_information
      
      mobile.location_rewrite '/:state/:city/:location.html', 
        :controller => 'mobile/locations', :action => :show, :state => STATE_PATTERN
      mobile.location_images_gallery '/images-gallery/location/:id',
        :controller => 'mobile/location_images', :action => :gallery
      
      mobile.location_directions '/directions/location/:id',
        :controller => 'shared/directions', :action => :show_location_directions
      mobile.location_at_map '/map/location/:id',
        :controller => 'shared/directions', :action => :show_location_at_map
      
      mobile.root :controller => 'mobile/index', :action => 'index'
    end
  end
  
  ## EXIT LINKS ----------------------------------------------------------------
  map.subdomain(:www, {:name => nil, :namespace => nil}) do |www|
    www.byebye '/exit', :controller => 'frontend/exit', :action => :byebye
    www.bye '/bye', :controller => 'frontend/exit', :action => :bye

    www.error '/error/:id.html', :controller => 'frontend/errors', :action => :show
    www.social '/social/:id', :controller => 'frontend/social', :action => :show

    www.general_terms_and_conditions "/#{I18n.t('shared.routes.general_terms_and_conditions')}.html", :controller => 'frontend/index', :action => :general_terms_and_conditions
    www.privacy_notice "/#{I18n.t('shared.routes.privacy_notice')}.html", :controller => 'frontend/index', :action => :privacy_notice
    www.registration_information "/#{I18n.t('shared.routes.registration_information')}.html", :controller => 'frontend/index', :action => :registration_information
    www.about_us "/#{I18n.t('shared.routes.about_us')}.html", :controller => 'frontend/index', :action => :about_us
    www.advertising_opportunities "/#{I18n.t('shared.routes.advertising_opportunities')}.html", :controller => 'frontend/index', :action => :advertising_opportunities

    #paths to seo optimized product images (GLOBAL_CONFIG[:coupon_merchant_images_cache_dir]):
    www.connect '/coupon_merchant_images/:image_type/:size/:id_sub_dir/:id.:format', 
      :controller => 'shared/images', :action => :get_coupon_merchant_image
    #paths to seo optimized product images (GLOBAL_CONFIG[:location_images_cache_dir]):
    www.connect '/location_images/:id_sub_dir/:id/:size/:seo_name.:format', 
      :controller => 'shared/images', :action => :get_location_image
    www.connect '/location_images/:id_sub_dir/:id/:size.:format', 
      :controller => 'shared/images', :action => :get_location_image


    www.namespace(:frontend) do |fe|
  #    fe.resources :states
  #    fe.resources :cities,
  #      :collection => {
  #        :search_by_zip_code => :get,
  #        :search_by_name     => :get
  #      }
  #    fe.resources :zip_codes
  #    fe.resources :locations,
  #      :collection => { :check  => :get },
  #      :member => { :confirm => :get }
  #    fe.resources :location_suggestions,
  #      :collection => { :check  => :get }
    end

    # search
    www.search '/suche.html', :controller => 'frontend/searches', :action => :search
    www.search_suggestions '/suchvorschlaege', :controller => 'frontend/searches', :action => :suggestions

    www.new_captcha "/#{I18n.t('shared.routes.new_captcha')}", 
      :controller => 'frontend/common', :action => :captcha

    www.new_location_suggestion "/#{I18n.t('shared.routes.new_location_suggestion')}.html", 
      :controller => 'frontend/location_suggestions', :action => :new
    www.frontend_location_suggestions '/frontend/location_suggestions', 
      :controller => 'frontend/location_suggestions', :action => :create,
      :conditions => {:method => :post}
    www.check_frontend_location_suggestions '/frontend/location_suggestions/check',
      :controller => 'frontend/location_suggestions', :action => :check

    www.coupon_categories "/#{I18n.t('shared.routes.coupon_categories')}", :controller => 'frontend/coupon_categories', :action => :index
    www.coupon_category   "/#{I18n.t('shared.routes.coupon_category')}/:rewrite/:page", :controller => 'frontend/coupon_categories', :action => :show, :page => nil, :trailing_slash => false
    www.search_coupons "/#{I18n.t('shared.routes.coupons')}/suche.html", :controller => 'frontend/coupons', :action => :search
    www.coupons "/#{I18n.t('shared.routes.coupons')}", :controller => 'frontend/coupons', :action => :index
    www.all_coupon_merchants "/#{I18n.t('shared.routes.coupons')}/alle-shops/:page", :controller => 'frontend/coupons', :action => :all_coupon_merchants, :page => nil, :trailing_slash => false
    www.merchant_coupons "/#{I18n.t('shared.routes.coupons')}/shop/:merchant_id/:page", :controller => 'frontend/coupons', :action => :all_merchant_coupons, :page => nil, :trailing_slash => false
    www.coupon "/#{I18n.t('shared.routes.coupon')}/:id", :controller => 'frontend/coupons', :action => :show

    # location
    www.location_rewrite '/:state/:city/:location.html', 
      :controller => 'frontend/locations', :action => :show, :state => STATE_PATTERN
    www.report_location_changes '/:state/:city/:location/report-changes', 
      :controller => 'frontend/locations', :action => :report_changes, :state => STATE_PATTERN,
      :conditions => {:method => :post}
    www.report_location_changes '/:state/:city/:location/report-changes', 
      :controller => 'frontend/locations', :action => :show_report_changes, :state => STATE_PATTERN,
      :conditions => {:method => :get}
    www.confirm_frontend_location_image '/:state/:city/:location/images/:id/confirm/:token', 
      :controller => 'frontend/location_images', :action => :confirm
    www.delete_frontend_location_image '/:state/:city/:location/images/:id/delete/:token', 
      :controller => 'frontend/location_images', :action => :delete
    www.connect '/frontend/location_images/:id/confirm', 
      :controller => 'frontend/location_images', :action => :confirm
    www.connect '/frontend/location_images/:id/delete', 
      :controller => 'frontend/location_images', :action => :delete
    www.new_location_image '/:state/:city/:location/new-image', 
      :controller => 'frontend/location_images', :action => :new, :state => STATE_PATTERN,
      :conditions => {:method => :get}
    www.create_location_image '/:state/:city/:location/new-image', 
      :controller => 'frontend/location_images', :action => :create, :state => STATE_PATTERN,
      :conditions => {:method => :post}
    www.compare_locations "/locations/compare", :controller => 'frontend/locations', :action => :compare
    www.new_location "/#{I18n.t('shared.routes.new_location')}.html", 
      :controller => 'frontend/locations', :action => :new
    www.frontend_locations '/frontend/locations', 
      :controller => 'frontend/locations', :action => :create,
      :conditions => {:method => :post}
    www.check_frontend_locations '/frontend/locations/check', 
      :controller => 'frontend/locations', :action => :check
    www.confirm_frontend_location '/frontend/locations/:id/confirm', 
      :controller => 'frontend/locations', :action => :confirm

    # city
    www.connect "/:state/:city/#{I18n.t('shared.routes.compare_prices_in_city')}",
      :controller => 'frontend/cities', :action => :redirect_to_show, :state => STATE_PATTERN
    www.connect "/:state/:city/#{I18n.t('shared.routes.compare_prices_in_city')}/:page", 
      :controller => 'frontend/cities', :action => :redirect_to_show, :state => STATE_PATTERN,
      :page => nil, :trailing_slash => false
    www.connect '/:state/:city.html', 
      :controller => 'frontend/cities', :action => :redirect_to_show, :state => STATE_PATTERN
    www.city_rewrite '/:state/:city/:page', 
      :controller => 'frontend/cities', :action => :show, :state => STATE_PATTERN,
      :page => nil, :trailing_slash => false
    www.search_by_name_frontend_cities '/frontend/cities/search_by_name', 
      :controller => 'frontend/cities', :action => :search_by_name
    www.search_by_zip_code_frontend_cities '/frontend/cities/search_by_zip_code', 
      :controller => 'frontend/cities', :action => :search_by_zip_code

    # state
    www.state_rewrite '/:state.html', 
      :controller => 'frontend/states', :action => :show, :state => STATE_PATTERN

    # new review
    www.new_location_review '/:state/:city/:location/reviews/new', 
      :controller => 'frontend/reviews', :action => :new, :state => STATE_PATTERN, :via => :get
    www.create_location_review '/:state/:city/:location/reviews', 
      :controller => 'frontend/reviews', :action => :create, :state => STATE_PATTERN, :via => :post
    www.confirm_review '/reviews/:id/:token', 
      :controller => 'frontend/reviews', :action => :confirm, :via => :get

    www.with_options({:name_prefix => 'community_', :path_prefix => 'community'}) do |c|
      www.with_options({:name_prefix => 'frontend_user_', :path_prefix => 'user'}) do |fu|
        fu.login '/login', :controller => 'frontend/user_sessions', :action => :new, :via => :get
        fu.login '/login', :controller => 'frontend/user_sessions', :action => :create, :via => :post
        fu.logout '/logout', :controller => 'frontend/user_sessions', :action => :destroy, :via => :delete

        fu.confirmation '/confirm/:confirmation_code', :controller => 'frontend/users', :action => :confirm, :via => :get
        fu.confirm_now '/confirm-now', :controller => 'frontend/users', :action => :confirm_now, :via => :get
        fu.confirm_later '/confirm-later', :controller => 'frontend/users', :action => :confirm_later, :via => :get

        fu.password_reset_request '/passwort-zuruecksetzen', :controller => 'frontend/password-reset-requests', :action => :new, :via => :get
        fu.password_reset_request '/passwort-zuruecksetzen', :controller => 'frontend/password-reset-requests', :action => :create, :via => :post
        fu.password_reset '/neues-passwort-vergeben/:id', :controller => 'frontend/password-reset-requests', :action => :edit, :via => :get
        fu.password_reset '/neues-passwort-vergeben', :controller => 'frontend/password-reset-requests', :action => :update, :via => :post

        fu.confirm_new_email '/confirm-my-new-email/:confirmation_code', :controller => 'frontend/users', :action => :confirm_new_email, :via => :get
        fu.confirm_new_email_now '/confirm-my-new-email-now', :controller => 'frontend/users', :action => :confirm_new_email_now, :via => :get

        fu.account '/account', :controller => 'frontend/community/users', :action => :account
      end

      #post 'review-author-log-on', :to => 'user_sessions#create_review_author', :as => :review_author_logon
      #post 'image-uploader-log-on', :to => 'user_sessions#create_image_uploader', :as => :image_uploader_logon
    end

    # Install the default routes as the lowest priority.
    # Note: These default routes make all actions in every controller accessible via GET requests. You should
    # consider removing or commenting them out if you're using named routes and resources.
    www.connect ':controller/:action/:id'
    www.connect ':controller/:action/:id.:format'

    www.connect '/backend', :controller=>'backend/index', :action=>'index'
    www.connect '/backend/:action', :controller=>'backend/index'

    www.root :controller => 'frontend/index', :action => 'index'
  end
end