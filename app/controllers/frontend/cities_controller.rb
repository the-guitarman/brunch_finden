class Frontend::CitiesController < Frontend::FrontendController
  skip_before_filter :set_page_header_tag_configurator, :set_page_header_tags, 
    :only => [:search_by_zip_code, :search_by_name]
  
  before_filter :find_city, :only => :show
  caches_action :show, :cache_path => :cache_city_path.to_proc
  #cache_sweeper :city_sweeper, :only => [:update, :create, :destroy]

  # ajax search suggestions
  def search_by_zip_code
    zip_codes = []
    if not (term = params[:term].to_s.strip).blank? and term.to_i > 0
      zip_codes = ZipCode.find(:all, :conditions => ["code = ?", term])
      zip_codes.compact!
    end
    render :json => format_suggested_cities_by_zip_code(zip_codes).to_json
  end
  
  def search_by_name
    @cities = []
    unless (term = params[:term].to_s.strip).blank?
      term = term.gsub(/([ ]{2,})/, ' ').gsub(' ', '%')
      @cities = City.find(:all, {
        :conditions => "name LIKE '#{term}%'", 
        :order => 'name ASC',
        :limit => 10
      })
    end
    render :json => format_suggested_cities(@cities).to_json
  end

  def show
    @page_header_tags_configurator.set_city(@city)
    limit = (@frontend_config['CITIES']['SHOW']['LIMIT']['LOCATIONS'] || 20 rescue 20)
    @locations = find_locations(@city, limit)
    
    @facebook_tags['og:type'] = 'city'
    @facebook_tags['og:url'] = city_rewrite_url(create_rewrite_hash(@city.rewrite))
    @facebook_tags['og:locality'] = @city.name
    @facebook_tags['og:region'] = @city.state.name
    
    @twitter_tags['twitter:url'] = city_rewrite_url(create_rewrite_hash(@city.rewrite))
  end
  
  def redirect_to_show
    parameters = params.copy.symbolize_keys
    parameters[:action] = :show
    redirect_to(city_rewrite_url(parameters), {:status => :moved_permanently})
  end

  private

  def find_city
    unless params[:city].blank?
      rewrite = "#{params[:state]}/#{params[:city]}"
      unless @city = City.find_by_rewrite(rewrite)
        raise(ActiveRecord::RecordNotFound)
      end
    else
      @city = City.find(params[:id])
    end
  end

  def find_locations(city, limit)
    @page = page
    @locations_limit = limit
    locations = city.locations.showable.paginate({
      :order => 'name ASC', 
      :page => @page, :per_page => @locations_limit
    })
#    location_ids = city.locations.showable.paginate({
#      :select => 'locations.id',
#      :order => 'name ASC', 
#      :page => @page, :per_page => @locations_limit
#    })
#    locations = Location.find(location_ids.map{|l| l.id})
#    locations.paginate!({
#      :page => @page, :per_page => @locations_limit,
#      :total_entries => city.locations.showable.count
#    })
    return locations
  end
  
  def format_suggested_cities(cities)
    ret = []
    cities.each do |city|
      ret << {
        :label => city.name,
      }
    end
    return ret
  end
  
  def format_suggested_cities_by_zip_code(zip_codes)
    ret = []
    zip_codes.each do |zip_code|
      temp = {:label => "#{zip_code.code} (#{zip_code.city.name})"}
      if params[:update_field]
        if zip_code.respond_to?(params[:update_value].to_s.to_sym)
          temp[params[:update_field].to_sym] = zip_code.send(params[:update_value].to_s.to_sym)
        end
      end
      ret << temp
    end
    return ret
  end
  
  def cache_city_path
    city_rewrite_cache_key(@city.rewrite, params)
  end
end
