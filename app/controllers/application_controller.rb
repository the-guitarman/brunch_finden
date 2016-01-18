#encoding: utf-8

class ApplicationController < ActionController::Base
#  include SslRequirement
#  include Mixins::EnsureHost

  # load and process global configurations
  before_filter :sanitize_params, :load_globals

  helper :all # include all helpers, all the time
  helper_method :google_analytics_property_id, :map_coordinates,
    :map_marker_data, :map_marker_coordinates, :map_marker_info, :map_marker_window
  
  # resque exceptions in production mode only
  if (Rails.env.production? or Rails.env.production_dev? or Rails.env.test?)
    # As the exception handlers list seems to be LIFO,
    # I need to register the top level exception handler first
    # followed by the specific exceptions. This ensures
    # that the handlers get traversed in the right order and
    # specific exceptions will be caught at the right handler.
    rescue_from Exception,                           :with => :render_error
    rescue_from ActiveRecord::RecordNotFound,        :with => :active_record_not_found_handler
    rescue_from ActionController::RoutingError,      :with => :routing_error_handler
    rescue_from ActionController::UnknownController, :with => :render_not_found
    rescue_from ActionController::UnknownAction,     :with => :render_not_found
    rescue_from ActionView::TemplateError,           :with => :render_error
  end
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # !!! :secret is deprecated
  protect_from_forgery #:secret => 'f086419d31635c733cc6c83ac37b5cbb'

  # Login passwords should not be accessible as clear text in log files.
  # To prevent you from this 'filter_parameter_logging key_1, key_2, ..., key_n'
  # replaces the values to all keys matching /key_1|key_2|...|key_n/i
  # with "[FILTERED]".
  filter_parameter_logging :password, 
    
  def google_analytics_property_id
    return 'UA-13272780-8'
  end

  protected

#  alias_method :original_local_request?, :local_request?
#  def local_request?
#    if Rails.env.test?
#      true
#    else
#      original_local_request?
#    end
#  end

  def render_optional_error_file(status_code, layout = nil)
    status = interpret_status(status_code)
    @error_status_code = status_code = status[0,3]
    if @page_header_tags_configurator
      @page_header_tags = @page_header_tags_configurator.set_error(status_code)
    end
    file_name = "/frontend/errors/#{status_code}.html.erb"
    if File.exist?("#{Rails.root}/app/views#{file_name}")
      render :template => file_name, :status => status, :layout => layout
    else
      render :template => "/frontend/errors/unknown.html.erb", :status => status, :layout => layout
    end
  end

  private

  def degrees_to_radians(deg)
    Math::PI * (deg % 360.0) / 180.0
  end
  
  def render_error(exception)
    unless manuel_routing_error_redirection(exception)
      Error.create_for(exception, 500, request, params)
      log_error(exception)
      #redirect_to error_url(:id => 500), :status => 301
      render_optional_error_file(500, 'frontend/standard')
    end
  end
  
  def render_not_found(exception, try_manuel_redirection = true)
    if try_manuel_redirection and manuel_routing_error_redirection(exception)
      return true
    else
      Error.create_for(exception, 404, request, params)
      log_error(exception)
      #redirect_to error_url(:id => 404), :status => 301
      render_optional_error_file(404, 'frontend/standard')
    end
  end
  
  def find_forwarding
    Forwarding.find_by_source_url(request.request_uri)
  end

  def active_record_not_found_handler(exception, try_manuel_redirection = true)
    path = request.path
    if path.match(/\/#{I18n.t('shared.routes.compare_prices_in_city')}\.html$/)
      redirect_to(path.gsub(/\/#{I18n.t('shared.routes.compare_prices_in_city')}\.html$/, "/#{I18n.t('shared.routes.compare_prices_in_city')}"), {:status => 301})
      return true
    end
    if forwarding = find_forwarding
      redirect_to(forwarding.destination_url, {:status => 301})
    else
      render_not_found(exception, try_manuel_redirection)
    end
  end
  
  def manuel_routing_error_redirection(exception)
    return false unless exception.is_a?(ActionController::RoutingError)
    path = request.path
    redirect_to_path = nil
    if path.match(/\/apple-touch-icon-precomposed\.(png|gif|jpg)/)
      redirect_to_path = '/images/apple_touch_icon.png'
    elsif path == '/favicon.de'
      redirect_to_path = '/favicon.ico'
    elsif path.match(/\/neue-brunch-location-eintragen\.html\+\+\+/)
      redirect_to_path = '/neue-brunch-location-eintragen.html'
    elsif path.start_with?('/kontakt') or path.start_with?('/impressum')
      redirect_to_path = registration_information_url
    elsif path.match(/^\/mobile/)
      redirect_to_path = path.gsub(/^\/mobile/, '')
    elsif path.match(/\/gutschein-kategorien\.html/)
      redirect_to_path = coupon_categories_url
    elsif path.match(/\/gutschein-kategorien\/(\d{1,})\.html/)
      if coupon_category = CouponCategory.find_by_id($1)
        redirect_to_path = coupon_category_url({:rewrite => coupon_category.rewrite})
      else
        redirect_to_path = coupon_categories_url
      end
    elsif path.match(/\/#{I18n.t('shared.routes.coupons')}\/(\d{1,})\.html/)
      redirect_to_path = "/#{I18n.t('shared.routes.coupon')}/#{$1}"
    elsif path.match(/\/www\.|\.php/)
      if forwarding = find_forwarding
        redirect_to_path = forwarding.destination_url
      else
        redirect_to_path = root_path
      end
    elsif path.match(/\/sidemap\.xml|\/sitemap\d{0,}\.xml|\/sitemap_index\.xml/)
      redirect_to_path = '/sitemap.xml.gz'
    end
    unless redirect_to_path.blank?
      redirect_to(redirect_to_path, {:status => 301})
      ret = true
    else
      ret = false
    end
    return ret
  end
  
  def routing_error_handler(exception)
    unless manuel_routing_error_redirection(exception)
      active_record_not_found_handler(exception, false)
    end
  end

  def sanitize_params
    params.each do |key, value|
      value = sanitize_parameters(value)
    end
  end

  def sanitize_parameters(value)
    if value.is_a?(Array)
      value.each do |val|
        val = sanitize_parameters(val)
      end
    elsif value.is_a?(Hash)
      value.each do |key, val|
        val = sanitize_parameters(val)
      end
    elsif value.is_a?(String)
      value.sanitize!
    end
    return value
  end

  def load_globals
    # load custom frontend config
    load_frontend_config
  end

  def load_frontend_config
    @frontend_config ||= CustomConfigHandler.instance.frontend_config
    if @frontend_config['DOMAIN'].blank?
      @host_name = 'unknown host name'
      @host_full_name = 'unknown host name'
    else
      if @frontend_config['DOMAIN']['NAME'].blank?
        @host_name = request.host
      else
        @host_name = @frontend_config['DOMAIN']['NAME']
      end
      if @frontend_config['DOMAIN']['FULL_NAME'].blank?
        @host_full_name = request.host
      else
        @host_full_name = @frontend_config['DOMAIN']['FULL_NAME']
      end
    end
    @host_full_name.capitalize!
    @host_full_name.downcase!
    @host_name.capitalize!
    @host_name.downcase!
    @locale = I18n.locale
#    @html_coder = HTMLEntities.new
  end
  
  # used within frontend and customer backend controllers
  def set_page_header_tag_configurator
    @page_header_tags_configurator = PageHeaderTagConfigurator.new(self)
  end

  # used within frontend and customer backend controllers
  def set_page_header_tags
    @page_header_tags = @page_header_tags_configurator.page_header_tags
  end

  def locations_close_to_this(location)
    locations_close_to_this = []
#    find_each_conf = {:batch_size => GLOBAL_CONFIG[:find_each_batch_size]}
#
#    # find locations with same zip code
#    zip_code = location.zip_code
#    locations_close_to_this += zip_code.locations.find(:all, {
#      :conditions => "id <> #{location.id}",
#      :limit => 3
#    })
#
#    if locations_close_to_this.length < 3
#      # city level
#      city = zip_code.city
#      zip_codes = city.zip_codes.find(:all, {
#        :conditions => "number_of_locations > 0",
#        :order => 'code'
#      })
#      unless zip_codes.empty?
#        while (zip_code != zip_codes.first) do
#          zc =  zip_codes.shift
#          zip_codes << zc
#        end
#        zip_codes.shift
#        zip_codes.each do |zip_code|
#          location_ids = locations_close_to_this.map{|l| l.id}
#          puts "2: #{location_ids.join(', ')}"
#          find_each_options = find_each_conf
#          find_each_options[:order] = 'rand()'
#          unless location_ids.empty?
#            find_each_options[:conditions] = "NOT id IN (#{location_ids.join(',')})"
#          end
#          zip_code.locations.find_each(find_each_options) do |l|
#            locations_close_to_this << l
#            break if locations_close_to_this.length >= 3
#          end
#          break if locations_close_to_this.length >= 3
#        end
#      end
#
#      if locations_close_to_this.length < 3
#        # random level
#        count = Location.count
#        puts "count: #{count}"
#        while (locations_close_to_this.length < 3) do
#          puts "locations_close_to_this: #{locations_close_to_this.length}"
#          location_ids = locations_close_to_this.map{|l| l.id}
#          unless location_ids.include?(location.id)
#            location_ids << location.id
#          end
#          puts "3: #{location_ids.join(', ')}"
#          locations = Location.find(:all, {
#            :conditions => "NOT id IN (#{location_ids.join(',')})",
#            :order => 'rand()',
#            :limit => 20
#          })
#          locations.each do |l|
#            if locations_close_to_this.length < 3
#              locations_close_to_this << l
#            else
#              break
#            end
#          end
#        end
#      end
#    end
#    puts "4: #{location_ids.join(', ')}"
    
    if ThinkingSphinx.sphinx_running? #not ThinkingSphinx.remote_sphinx? and 
      if geo_location = location.geo_location
        begin
          locations_close_to_this = Location.search({
            :without => {:id => location.id},
            :geo => [
              degrees_to_radians(geo_location.lat),
              degrees_to_radians(geo_location.lng)
            ],
            :order => "@geodist ASC", #, @relevance DESC,
            :per_page => 4
          })
          locations_close_to_this.error?
        rescue Riddle::ConnectionError => e
          locations_close_to_this = []
        end
      end
    end
    
    return locations_close_to_this || []
  end
  
  def map_marker_data(location, center = false)
    ret = []
    if gl = location.geo_location
      ret.push(map_marker_coordinates(gl)) if center
      ret.push(map_marker_coordinates(gl).merge(map_marker_info(location)))
    end
    return ret
  end
  
  def map_marker_coordinates(geo_location)
    return {:lat => geo_location.lat, :lng => geo_location.lng}
  end
  
  def map_marker_info(location)
    return {
      :title => location.name.strip.gsub('"',"'").gsub("\n",""),
      :icon => {
        :url => "http://#{@frontend_config['DOMAIN']['FULL_NAME']}" + self.class.helpers.path_to_image('gmaps_marker.png')
      }
    }
  end
  
  def map_marker_window(location, geo_location)
    return {
      :info_window => {
        :content => self.class.helpers.link_to(
          geo_location.geo_code.name.gsub("\"", "'").gsub("\n",""), 
          location_rewrite_url(create_rewrite_hash(geo_location.geo_code.rewrite)),
          :class => 'gmap-link'
        )
      }
    }
  end
end
