class Mobile::LocationSuggestionsController < Mobile::MobileController
  include Frontend::YacaphHelper
  
  caches_page :new
  
  skip_before_filter :set_page_header_tag_configurator, :set_page_header_tags, 
    :only => [:create, :update, :check]
  
  def new
    @location_suggestion = LocationSuggestion.new
  end
  
  def create
    @location_suggestion = LocationSuggestion.new(params[:location_suggestion])
    if @location_suggestion.valid? and yacaph_validated?
      @location_suggestion.save
      render :action => :create
    else
      @cities = []
      if !params[:location_suggestion].blank? and !params[:location_suggestion][:city].blank?
        @cities = City.find(:all, :conditions => "name LIKE '#{params[:location_suggestion][:city]}%'")
      end
      render :action => :new
    end
  end
  
  def check
    respond_to do |format|
      format.js do
        @result = ''
        check = params['check'] || {}
        location_suggestion_keys = check.keys
        unless location_suggestion_keys.empty?
          location_suggestion_attribute = location_suggestion_keys.first

          attributes = {}
          attributes[location_suggestion_attribute.to_sym] = check[location_suggestion_attribute]
          location_suggestion = LocationSuggestion.new(attributes)
          location_suggestion_attribute = location_suggestion_attribute.gsub('amount_field_', '')
          if not location_suggestion.valid? and not location_suggestion_keys.empty?
            @result = location_suggestion.errors.on(location_suggestion_attribute.to_sym).to_s
          end
          @attribute = location_suggestion_attribute
        end
        render(:action => 'check.js.rjs', :layout => false)
      end
      format.html do
        redirect_to root_url, :status => 301
      end
    end
  end
end