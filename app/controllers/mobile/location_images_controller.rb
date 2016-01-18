class Mobile::LocationImagesController < ApplicationController
  def gallery
    find_location
    #images = @location.images.showable.published.find(:all, {:order => 'is_main_image DESC'})
    images = @location.images.showable.find(:all, {:order => 'is_main_image DESC'})
    render({
      :partial => 'mobile/location_images/location_images',
      :locals => {:images => images}
    })
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
