module Frontend::LocationsHelper
  def field_message(message, show_ok_icon=false)
    ret = ''
    if (message.is_a?(Array) and !message.empty?) or not message.blank?
      ret = '<div class="field-message-icon">' + form_item_error_icon + '</div>' +
            '<div class="field-message">'
      if message.is_a?(Array)
        message.each do |msg|
          ret += '<div class="message">' + msg + '</div>'
        end
      else
        ret += '<div class="message">' + message + '</div>'
      end
      ret += '</div>'
    elsif show_ok_icon == true
      ret = '<div class="field-message">' +
              '<div class="icon">' + form_item_ok_icon + '</div>' +
            '</div>'
    end
    return ret
  end
  
  def get_location_image_in_fancybox_link(image, image_options, options)
    ret = get_location_image_tag(image, image_options)
    if image and not image.id == 0
      content = image_options.delete(:content) || ret
      css_class = 'lightbox'
      css_class += " #{options[:extra_css_class]}" unless options[:extra_css_class].blank?
      title = image.title? ? image.title : nil
      if author = user_short(image)
        title = "von #{user_name(author)}, #{l(image.created_at)}"
        title += ": #{image.title}" if image.title?
      end
      sizes = LocationImage::IMAGE_RENDER_SIZES[:location].split('x').map{|el| el.to_i}
      if sizes[0] < image.image_width or 
         sizes[1] < image.image_height or 
         options[:only_larger_image] == false
        ret = link_to(
          content, 
          get_location_image_path(image, {:size => :fancybox}), 
          {:class => css_class, :rel => options[:gallery], :title => title}
        )
        if author
          location = image.location
          ret += schema_org_photo_author(author, {:class => 'hidden'})
          ret += schema_org_photo_content_location(location, {:class => 'hidden'})
          ret += schema_org_photo_date_published(location, {:class => 'hidden'})
        end
      end
    end
    return ret
  end
  
  def get_location_content_in_fancybox_link(content, image, options = {})
    css_class = 'lightbox'
    css_class += " #{options[:extra_css_class]}" unless options[:extra_css_class].blank?
    title = image.title? ? image.title : nil
    sizes = LocationImage::IMAGE_RENDER_SIZES[:lightbox].split('x').map{|el| el.to_i}
    if sizes[0] < image.image_width or 
       sizes[1] < image.image_height or 
       options[:only_larger_image] == false
      ret = link_to(
        content, 
        get_location_image_path(image, {:size => :lightbox}),
        {:class => css_class, :rel => options[:gallery], :title => title}
      )
    elsif options[:only_larger_image] == true
      ret = nil
    else
      ret = content.html_safe
    end
    return ret
  end
end