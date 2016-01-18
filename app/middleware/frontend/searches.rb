class Frontend::Searches
  include SearchQuery::Logger
  
  def initialize(app)
    @app = app
    @ug = UrlGenerator.new
  end
  
  def call(env)
    if env["PATH_INFO"] == "/suchvorschlaege"
      request = Rack::Request.new(env)
      [200, {'Content-Type' => Mime::JSON.to_s}, [suggestions(request.params['term'])]]
    else
      @app.call(env)
    end
  end
  
  private
  
  def suggestions(term)
    search_str = term.to_s.strip
    search_str = Riddle.escape(search_str) if defined?(Riddle)
    
    log_search_query('suggestion', search_str)
    
    Rails.cache.fetch(["global-search-suggestions", search_str].join('_')) do
      search_options = {
        :order => '@relevance DESC',
        #:classes       => [],
        :match_mode    => :extended,
        #:with          => {:showable => true},
        :ignore_errors => !Rails.env.development?,
        :max_matches   => 10, # 1000,
        :page          => 1, 
        :per_page      => 10
      }
      
      locations = Location.search(search_str, search_options.merge({:with => {:showable => true}}))
      locations = format_suggested_locations(search_str, locations)

      cities = City.search(search_str, search_options.merge({:without => {:number_of_locations => 0}}))
      cities = format_suggested_cities(search_str, cities)

      coupons = Coupon.search(search_str, search_options.merge({:with => {:valid_to => DateTime.now..(DateTime.now + 1.year)}}))
      coupons = format_suggested_coupons(search_str, coupons)
      
      locations + cities + coupons
    end.to_json
  end
  
  def format_suggested_locations(search_str, locations)
    ret = []
    locations.each do |location|
      ret << {
        :label => location.name,
        :url => @ug.location_rewrite_url(create_rewrite_hash(location.rewrite)),
        :category => "Brunch Locations zu <b>#{search_str}</b>"
      }
    end
    return ret
  end
  
  def format_suggested_cities(search_str, cities)
    ret = []
    cities.each do |city|
      ret << {
        :label => city.name,
        :url => @ug.city_rewrite_url(create_rewrite_hash(city.rewrite)),
        :category => "Orte zu <b>#{search_str}</b>"
      }
    end
    return ret
  end
  
  def format_suggested_coupons(search_str, coupons)
    ret = []
    coupons.each do |coupon|
      ret << {
        :label => coupon.name,
        :url => @ug.city_rewrite_url(create_rewrite_hash(coupon.rewrite)),
        :category => "Gutscheine zu <b>#{search_str}</b>"
      }
    end
    return ret
  end
end