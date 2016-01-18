class Frontend::LocationImagesController < Frontend::FrontendController
  
  #skip_before_filter :set_page_header_tag_configurator, :set_page_header_tags, 
  #  :only => [:new, :create]
  
  before_filter :find_location
  
  def new
    @location_image = LocationImage.new
    @frontend_user = FrontendUser.new
    @page_header_tags_configurator = PageHeaderTagConfigurator.new(self) if request.xhr?
    @page_header_tags_configurator.set_location(@location)
    if request.xhr? 
      render({
        :partial => 'frontend/location_images/new', 
        :locals => {
          :location => @location,
          :location_image => @location_image,
          :frontend_user => @frontend_user
        },
        :content_type => Mime::HTML
      })
    else
      #redirect_to(location_rewrite_url(create_rewrite_hash(@location.rewrite)), {:status => 301})
      render({:template => 'frontend/location_images/new'})
    end
  end
  
  def create
    @objects_to_validate = []
    
    autologin_the_user
    
    # frontend user
    @frontend_user = find_or_initialize_frontend_user
    @objects_to_validate << @frontend_user if @frontend_user.new_record?

    unless logged_in?
      @new_frontend_user = @frontend_user
      @new_frontend_user_session = FrontendUserSession.new
    end
    
    # location image
    attributes = params[:location_image] || {}
    attributes.merge!({
      :location => @location, 
      :frontend_user => @frontend_user,
      :data_source => DataSource.standard,
      :presentation_type => LocationImage::PRESENTATION_TYPES.last #,
      #:uploader_denied_main_image => params[:as_main_image].blank?
    })
    @location_image = LocationImage.new(attributes)
    @objects_to_validate << @location_image
    if logged_in?
      @location_image.general_terms_and_conditions = true
    elsif params[:location_image]
      @location_image.general_terms_and_conditions = params[:location_image][:general_terms_and_conditions]
    end
    
    # validation check
    @all_valid = validate_objects(*@objects_to_validate)
    
    @page_header_tags_configurator = PageHeaderTagConfigurator.new(self) if request.xhr?
    @page_header_tags_configurator.set_location(@location)
    
    unless @all_valid
      # show new location image template with errors
      unless request.xhr?
        render({:template => 'frontend/location_images/new'})
      else
        render({:template => 'frontend/location_images/create.js.rjs'})
      end
    else
      @frontend_user.save
      @location_image.frontend_user = @frontend_user
      if @location_image.save
        Mailers::Frontend::LocationMailer.deliver_confirm_location_image(@location_image)
      end
      unless request.xhr?
        if logged_in?
          redirect_to(location_rewrite_url(create_rewrite_hash(@location.rewrite)))
        else
          render({:template => 'frontend/location_images/create'})
        end
      else
        render({:template => 'frontend/location_images/create.js.rjs'})
      end
    end
  end

  def confirm
    if @location_image = LocationImage.find_by_confirmation_code(params[:token].to_s.strip)
      @page_header_tags_configurator.set_location(@location)
      unless @location_image.update_attributes({:published => true, :confirmation_code => nil})
        error_message = "Das Brunch-Location-Bild 'id: #{@location_image.id}' konnte nicht bestätigt werden.\n\n"
        unless @location_image.errors.empty?
          error_message += "Fehler:\n"
          @location_image.errors.each do |k,v|
            error_message += "#{k}: #{v.inspect}\n"
          end
        end
        Mailers::AdminMailer.deliver_report_error(error_message)
      end
    elsif params[:id]
      @location_image = LocationImage.find(:first, {:conditions => {:id => params[:id]}})
      unless @location_image
        error_message = "LocationImage not found for: #{request.url}\n\n"
        Mailers::AdminMailer.deliver_report_error(error_message)
      end
    end
  end

  def delete
    @page_header_tags_configurator.set_location(@location)
    if @location_image = LocationImage.find_by_confirmation_code(params[:token].to_s.strip)
      @location_image.destroy
      unless @location_image.frozen?
        error_message = "Das Brunch-Location-Bild 'id: #{@location_image.id}' konnte nicht gelöscht werden.\n\n"
        Mailers::AdminMailer.deliver_report_error(error_message)
      end
    elsif params[:id]
      @location_image = LocationImage.find(:first, {
        :conditions => {:id => params[:id], :published => true}
      })
      unless @location_image
        error_message = "LocationImage not found for: #{request.url}\n\n"
        Mailers::AdminMailer.deliver_report_error(error_message)
      end
      redirect_to(location_rewrite_url(create_rewrite_hash(@location.rewrite)))
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
      location_image = LocationImage.find(params[:id])
      @location = location_image.location
    end
  end
end