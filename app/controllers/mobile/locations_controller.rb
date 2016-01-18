class Mobile::LocationsController < Mobile::MobileController
  include Frontend::YacaphHelper
  include Mixins::ReviewRating
  include Mixins::Review
  include Shared::LocationImagesHelper 

  caches_page :show
#  cache_sweeper :location_sweeper, :only => [:update, :create, :destroy]

  #protect_from_forgery :except => :confirm
  
  def show
    find_location
    #@images = @location.images.showable.published.find(:all, {:order => 'is_main_image DESC'})
    #@images = @location.images.showable.find(:all, {:order => 'is_main_image DESC'})
    
    @locations_close_to_this = locations_close_to_this(@location)

    if gl = @location.geo_location
      @map_locations = [
        {:lat => gl.lat, :lng => gl.lng}, 
        {
          :lat => gl.lat, :lng => gl.lng, :title => @location.name,
          :icon => {
            :url => "http://#{@frontend_config['DOMAIN']['FULL_NAME']}" + self.class.helpers.path_to_image('gmaps_marker.png'), 
            :scaled_size => 'new google.maps.Size(32,32)'
          }
        }
      ]
    end
    
    @page_header_tags_configurator.set_location(@location)
    
    get_review_template_with_questions(@location)
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
