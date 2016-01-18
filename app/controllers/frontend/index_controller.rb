class Frontend::IndexController < Frontend::FrontendController
  caches_page :index, 
    #:unless => proc{|c| c.logged_in? or c.request.xhr?}, 
    #:expires_in => 3.hours,
    :cache_path => proc {|c|
      parameters = c.params
      parameters.delete(:utf8)
      if mobile_device?
        {:mobile_device => true}+parameters
      end
      parameters
    }
  caches_page :general_terms_and_conditions, :privacy_notice,
    :registration_information, :about_us, :advertising_opportunities

  def index
    @images = LocationImage.find(:all, {:conditions => "image_height >= 559", :order => 'RAND()', :limit => 5})
    @image_size = LocationImage::IMAGE_RENDER_SIZES[:fancybox].split('x')
    
    # map locations
    #@map_locations = map_locations
    
    unless fragment_exist?(frontend_index_ct_states)
      @states = State.find(:all, :order => 'name ASC')
    end
    
    unless fragment_exist?(frontend_index_ct_city_with_most_locations)
      @cities_with_most_locations = City.find(:all, {
        :order => 'number_of_locations DESC',
        :limit => 16
      })
    end
    
    unless fragment_exist?(frontend_index_ct_latest_locations)
      @latest_locations = Location.showable.find(:all, {
        :order => 'created_at DESC', 
        :limit => 11
      })
    end
    
    unless fragment_exist?(frontend_index_ct_latest_reviews)
      @latest_reviews = Review.showable.find(:all, {
        :conditions => {:state => Review::STATES[:published]},
        :order => 'created_at DESC', 
        :limit => 4
      })
    end
    
    unless fragment_exist?(frontend_index_ct_latest_coupons)
      @latest_coupons = Coupon.find(:all, {
        :conditions => ['valid_to > ?', DateTime.now],
        :order => 'created_at DESC',
        :limit => 2
      })
    end
  end

  def general_terms_and_conditions
    @info_email = info_email
  end

  def privacy_notice
    @info_email = info_email
  end

  def registration_information

  end

  def about_us
    
  end
  
  def advertising_opportunities
    ao = CustomConfigHandler.instance.advertising_opportunities
    @advertising_opportunities = ao.to_s.gsub('__INFO_EMAIL__', info_email)
    @info_email = info_email
  end

  private
  
  def map_locations
    locations = nil
    mc_fl_key = 'frontend_index_locations'
    if not Rails.env.test? and mc_fl_value = Rails.cache.read(mc_fl_key)
      locations = mc_fl_value[:locations]
    end
    unless locations
      # center the map
      locations = [{:lat => 51.0625727100299, :lng => 10.17333984375}]

      # geo locations
      geo_locations = GeoLocation.find(:all, :conditions => {:geo_code_type => 'Location'})
      geo_locations.each do |gl|
        options = map_marker_coordinates(gl)
        options.merge!(map_marker_info(gl.geo_code))
        options.merge!(map_marker_window(gl.geo_code, gl))
        locations.push(options)
      end
    end
    return locations
  end

  def info_email
    fec = CustomConfigHandler.instance.frontend_config
    return "info(at)#{fec['DOMAIN']['NAME']}".to_hex
  end
end
