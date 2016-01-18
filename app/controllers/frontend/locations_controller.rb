require 'jobs/sitemap'
require 'lib/uri_fetcher'

class Frontend::LocationsController < Frontend::FrontendController
  include Frontend::YacaphHelper
  include Mixins::ReviewRating
  include Mixins::Review
  include Shared::LocationImagesHelper
  
  skip_before_filter :set_page_header_tag_configurator, :set_page_header_tags, 
    :only => [:update, :check] # :create, 
  
  before_filter :check_for_mobile, :only => :show

  caches_page :new, :show
#  cache_sweeper :location_sweeper, :only => [:update, :create, :destroy]

  #protect_from_forgery :except => :confirm
  
  def show
    find_location
    #@images = @location.images.showable.published.find(:all, {:order => 'is_main_image DESC'})
    @images = @location.images.showable.find(:all, {:order => 'is_main_image DESC'})
    
    location_url = location_rewrite_url(create_rewrite_hash(@location.rewrite))
    
    if @images.length > 0
      image_path = root_url + get_location_image_path(@images.first, {:size => :fancybox})
    else
      image_path = "#{root_url}/images/logo_de_cup.jpg"
    end
    image_path.gsub!('//', '/')
    
    @facebook_tags['og:type'] = 'restaurant'
    @facebook_tags['og:url'] = location_url
    @facebook_tags['og:image'] = image_path
    
    if geo_location = @location.geo_location
      @facebook_tags['og:latitude'] = geo_location.lat
      @facebook_tags['og:longitude'] = geo_location.lng
    end
    @facebook_tags['og:street-address'] = @location.street
    @facebook_tags['og:locality'] = @location.zip_code.city.name
    @facebook_tags['og:region'] = @location.zip_code.city.state.name
    @facebook_tags['og:postal-code'] = @location.zip_code.code
    @facebook_tags['og:country-name'] = 'Germany'
    @facebook_tags['og:email'] = @location.email if @location.email?
    @facebook_tags['og:phone_number'] = @location.phone if @location.phone?
    @facebook_tags['og:fax_number'] = @location.fax if @location.fax?
    
    @twitter_tags['twitter:url'] = location_url
    @twitter_tags['twitter:image'] = image_path
    
    @schema_org_tags['image'] = image_path
    
    @locations_close_to_this = locations_close_to_this(@location)

    @map_locations = map_marker_data(@location, true)
    
    @page_header_tags_configurator.set_location(@location)
    
    get_review_template_with_questions(@location)
  end
  
  def show_report_changes
    find_location
    if request.xhr?
      render({
        :partial => 'frontend/locations/report_changes', 
        :locals => {:location => @location},
        :content_type => Mime::HTML
      })
    else
      redirect_to location_rewrite_url(create_rewrite_hash(@location.rewrite)), :status => 301
    end
  end
  
  def report_changes
    find_location
    @changes_validated = (not params[:changes].blank?)
    @yacaph_validated = yacaph_validated?
    if @changes_validated and @yacaph_validated
      Mailers::Frontend::LocationMailer.deliver_report_changes(@location, params[:changes])
    end
    render({:template => 'frontend/locations/report_changes.js.rjs'})
  end
  
  def compare
    ids = params[:ids].map{|el| el.to_s.split('_').last.to_i}
    @locations = Location.find(:all, {:conditions => {:id => ids}})
    if request.xhr?
      render({:partial => 'frontend/locations/compare', :layout => false})
    else
      render({:template => 'frontend/locations/compare'})
    end
  end

  def new
    @location = Location.new
    @frontend_user = FrontendUser.new
    @zip_code = ''
  end

  def create
    objects_to_validate = []
    
    # frontend user
    @frontend_user = find_or_initialize_frontend_user
    objects_to_validate << @frontend_user if @frontend_user.new_record?
    
    @location = Location.new(params[:location])
    @location.frontend_user = @frontend_user
    objects_to_validate << @location
    
    if validate_objects(*objects_to_validate)
      @frontend_user.save
      if @location.save
        Mailers::Frontend::LocationMailer.deliver_confirm_location(@location)
      end
      render({:template => 'frontend/locations/create'})
    else
      zip_code = @location.zip_code
      unless zip_code.blank?
        @zip_code = "#{zip_code.code} (#{zip_code.city.name})"
      else
        @zip_code = ''
      end
      render({:template => 'frontend/locations/new'})
    end
  end

#  def edit
#    @location = Location.find(params[:id])
#    @page_header_tags_configurator.set_location(@location)
#  end
#
#  def update
#    @location = Location.find(params[:location][:id])
#    @location.update_attributes(params[:location])
#    if @location.errors.empty?
#      flash[:info] = t('shared.saved_successfully')
#      redirect_to root_url
#    else
#      render :action => :edit
#    end
#  end

  def check
    respond_to do |format|
      format.js do
        @result = ''
        check = params['check'] || {}
        location_keys = check.keys
        unless location_keys.empty?
          if location_keys.length > 1
            if location_keys.include?('name')
              location_attribute = 'name'
            else
              location_attribute = location_keys.first
            end
          else
            location_attribute = location_keys.first
          end

          unless location_attribute.start_with?('frontend_user')
            location = Location.new({location_attribute.to_sym => check[location_attribute]})
            if location_attribute == 'name'
              location.send(:name=, check['name'])
              unless check['zip_code_id'].blank?
                if zip_code = ZipCode.find_by_id(check['zip_code_id'])
                  location.send(:zip_code_id=, zip_code.id)
                end
              end
            end
            location_attribute = location_attribute.gsub('amount_field_', '')
            if not location.valid? and not location_keys.empty?
              @result = location.errors.on(location_attribute.to_sym).to_s
            end
            @attribute = "location_#{location_attribute}"
          else
            user_keys = check[location_attribute].keys
            unless user_keys.empty?
              user_attribute = user_keys.first
              fu_attributes = {user_attribute.to_sym => check[location_attribute][user_attribute]}
              frontend_user = FrontendUser.find(:first, :conditions => fu_attributes)
              frontend_user = FrontendUser.new(fu_attributes) unless frontend_user
              #frontend_user.send("#{user_attribute.to_sym}=", check[location_attribute][user_attribute])
              user_attribute = user_attribute.gsub('amount_field_', '')
              if not frontend_user.valid? and not user_keys.empty?
                @result = frontend_user.errors.on(user_attribute.to_sym).to_s
              end
            end
            @attribute = "#{location_attribute}_#{user_attribute}"
          end
        end
        render(:action => 'check.js.rjs', :layout => false)
      end
      format.html do
        redirect_to root_url, :status => 301  
      end
    end
  end

  def confirm
    if @location = Location.find_by_confirmation_code(params[:token].to_s.strip)
      unless @location.update_attributes({:published => true, :confirmation_code => nil})
        error_message = "Die Brunch-Location '#{@location.name} (id: #{@location.id})' konnte nicht bestätigt werden.\n\nFehler:\n"
        @location.errors.each do |k,v|
          error_message += "#{k}: #{v.inspect}\n"
        end
        Mailers::AdminMailer.deliver_report_error(error_message)
      else
        ProjectSitemap.new.run
      end
    elsif params[:id]
      @location = Location.find(:first, {
        :conditions => {:id => params[:id], :published => true}
      })
      if @location
        redirect_to location_rewrite_url(create_rewrite_hash(@location.rewrite))
      else
        error_message = "Location not found for: #{request.url}\n\n"
        Mailers::AdminMailer.deliver_report_error(error_message)
      end
    end
  end
  
  private
  
  def find_location
    unless params[:location].blank?
      rewrite = "#{params[:state]}/#{params[:city]}/#{params[:location]}"
      unless @location = Location.find_by_rewrite(rewrite)
        raise(ActiveRecord::RecordNotFound)
      end
    else
      @location = Location.find(params[:id])
    end
    if @location and @location.published == false
      raise(ActiveRecord::RecordNotFound)
    end
  end
end
