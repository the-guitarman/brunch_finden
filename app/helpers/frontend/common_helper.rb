module Frontend::CommonHelper
  def clean_url(url)
    url.gsub('//', '/')
  end
  
  def nl2br(content) 
		return content.
      gsub(/\r\n/, '<br />').
      gsub(/\n/, '<br />').
      gsub(/\r/, '<br />').html_safe
	end
  
  def item_is_loading(text = '')
    ret = '<span class="item-is-loading">'
    ret = image_tag('loading.gif', {:alt => ''}) + '<br />'
    unless text.blank?
      ret += text
    end
    ret += '</span>'
    return ret
  end
  
  # The method looks for a translation of the given key parameter in scope
  # of the given action name. This is useful, if you know that a translation 
  # exits but it lives in another action of your controller.
  def translate_for_action(action, key, options = {})
    unless controller = options.delete(:controller)
      controller = params[:controller]
    end
    t("#{controller.to_s.gsub('/','.')}.#{action}.#{key}", options)
  end
  alias :t_f_a :translate_for_action
  
  def distance_in_minutes(date_time)
    return (((date_time - DateTime.now).abs)/60).round
  end
  
  def distance_in_days(date_time)
    return (distance_in_minutes(date_time).to_f / 1440.0).round
  end

  def is_integer?(decimal)
    ret = decimal.to_f
    d_10 = decimal.to_f * 10
    if (d_10 - d_10.to_i) == 0
      ret = ret.to_i
    end
    return ret
  end
  
#  # returns relevant virtual_path separated by dash without first element (frontend)
#  # ex.: frontend/products/show/_ct_foobar => products-ct_foobar
#  def template_partial_path
#    site_path_parts=@virtual_path.split("/")
#    [site_path_parts[1],site_path_parts[-1].gsub(/^_/,'')].join("-")
#  end
end