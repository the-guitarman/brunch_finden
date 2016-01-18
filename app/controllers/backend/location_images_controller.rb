class Backend::LocationImagesController < Backend::BackendController
#  include Backend::IndexHelper

#  def list
#    fui = LocationImage.where({:frontend_user_id => params[:frontend_user_id]})
#    fui = includes(fui)
#    count = fui.count
#    fui = filter(sorted(paginated(fui))).all
#    add_attributes(fui)
#    render :json => fui.to_ext_json({
#      :count => count,
#      :format => :plain, 
#      :include => :frontend_user
#    })
#  end
  
  def list_to_check
    #fui = LocationImage.where({:status => LocationImage::NEW_IMAGE_STATE})
    #fui = includes(fui)
    #count = fui.count
    #fui = filter(sorted(paginated(fui))).all
    
    fui = LocationImage.paginate({
      :conditions => [
        "status = ? AND presentation_type = ? AND created_at <= ?", 
        LocationImage::NEW_IMAGE_STATE,
        LocationImage::PRESENTATION_TYPES.last,
        Time.now.ago(LocationImage::UNPUBLISHED_VALID_FOR.hours)
      ]
    } + paging)
    count = fui.total_entries
    
    add_attributes(fui)
    render :json => fui.to_ext_json({
      :count => count,
      :format => :plain, 
      :include => :frontend_user
    })
  end
  
  def allow_or_deny
    fui = LocationImage.find(params[:id])
    if params[:image_action] == 'deny'
      if fui.status == LocationImage::NEW_IMAGE_STATE
        fui.destroy
        #if fui.frozen? and params[:send_an_email]
        #  Backend::FrontendUserMailer.profile_image_denied(fui.frontend_user, params[:send_an_email]).deliver
        #end
      end
    else
      fui.update_attributes({:status => LocationImage::CHECKED_IMAGE_STATE})
      add_attributes([fui])
    end
    render :json => fui.to_ext_json({:format => :plain, :include => :frontend_user})
  end
  
  private
  
  def add_attributes(images, options = {})
    images.each do |i|
      add_attributes_to_user(i, options)
    end
  end
  
  def add_attributes_to_user(image, options={})
    image['image_url'] = get_location_image_path(image, {:size => :location})
  end
end
