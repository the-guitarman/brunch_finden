module Frontend::ExitLinksHelper
  def link_to_coupon_exit(content, coupon, track_fields = {}, options = {})
    link_to(content, coupon_exit_url(coupon, track_fields), {
        :target => '_blank', :rel => :nofollow
      }.merge(options)
    ).html_safe
  end
  
  def coupon_exit_url(coupon, track_fields = {})
    get_byebye_url(coupon, 'url', track_fields).html_safe
  end
  
  private

  # Creates exit link urls for an object.
  def get_byebye_url(object, object_attribute_or_method, track_fields = {})
    # Set model name and attribute/method to call for the destination object.
    # Set destination object parameters.
    parameters = {:m => object.class.name, :id => object.id}
    if object_attribute_or_method
      parameters[:c] = object_attribute_or_method
    else
      parameters[:el] = track_fields[:el]
      track_fields.delete(:el)
    end

    # Translate field name parameters to url parameters.
    Clickout::URL_PARAMETERS.each do |field_name, url_param_name|
      unless track_fields[field_name].blank?
        parameters[url_param_name] = track_fields[field_name]
      end
    end
    
    parameters.each do |k,v|
      unless k.to_s.end_with?('id')
        parameters[k] = URI.encode(Base64.encode64(v.to_s))
      end
    end

    # Create exit link.
    byebye_url(parameters).gsub('&', '&amp;') #.html_safe
  end
end