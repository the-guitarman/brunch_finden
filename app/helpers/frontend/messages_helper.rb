module Frontend::MessagesHelper
  def form_entry_error(object, field = nil)
    ret = ''
    if object
      if field and object.errors[field].any?
        ret = ' error'
      elsif object.errors.any?
        ret = ' error'
      end
    end
    return ret.html_safe
  end
  
  def field_errors(item, attribute)
    ret = item.errors[attribute.to_sym]
    ret.uniq! if ret.is_a?(Array)
    return ret
  end

  def show_field_error(item, attribute)
    ret = ''
    errors = field_errors(item, attribute)
    unless errors.blank?
      ret = '<div class="tooltip error">'
      errors.each do |e|
        ret += "#{e}<br />"
      end
      ret += '<span class="end"></span></div>'
    end
    return ret.html_safe
  end

  def has_field_error(item, attribute)
    errors = field_errors(item, attribute)
    if errors.blank? or errors.empty?
      return false
    else
      return true
    end
  end

  def field_error_class(item, attribute)
    return has_field_error(item, attribute) ? ' error' : ''
  end
  
  def tooltip(messages, left_side = false, css_class = '')
    ret = ''
    messages_html = build_messages(messages)
    unless messages_html.blank?
      css_class = ' ' + css_class.strip unless css_class.blank?
      css_class += ' left' if left_side
      ret = "<div class=\"tooltip#{css_class}\">" +
              '<div class="nook"></div>' +
              '<div class="message">' +
                h(messages_html) +
              '</div>' +
            '</div>'
    end
    return ret.html_safe
  end
  
  def tooltip_error(messages, left_side = false)
    return tooltip(messages, left_side, 'error')
  end
  
  def infobox(messages, css_class = '', checkmark = false)
    ret = ''
    messages_html = build_messages(messages)
    unless messages_html.blank?
      css_class = ' ' + css_class.strip unless css_class.blank?
      ret = "<div class=\"infobox#{css_class}\">" +
              messages_html +
            '</div>'
      if checkmark
        ret = "<div class=\"infobox#{css_class}\">" +
                  "<div class=\"checkmark\">#{image_tag("/images/frontend/checkmark.png", {:size => '24X24'})}</div>" + 
                  '<div class="bg-image close"></div>' +
                  '<div class="message-checkmark">' + messages_html + '</div>' + 
              '</div>'
      end
    end
    return ret.html_safe
  end
  
  def infobox_error(messages)
    return infobox(messages, 'error')
  end
  
  def text_message(messages, css_class = '', close = false)
    ret = ''
    if close
      closer = content_tag(:div, '', {:class => 'bg-image close', :title => I18n.t('shared.close.text_message')})
    else
      closer = ''
    end
    messages_html = build_messages(messages, close)
    unless messages_html.blank?
      css_class = ' ' + css_class.strip unless css_class.blank?
      ret = "<div class=\"text-message#{css_class}\">" +
              messages_html + closer +
            '</div>'
    end
    return ret.html_safe
  end
  
  def text_message_error(messages, css_class='', close = false)
    return text_message(messages, "error #{css_class}".strip, close)
  end
  
  def build_messages(messages, close = false)
    ret = ''
    css_class = (close ? 'left' : nil)
    if messages.is_a?(Array) and not messages.empty?
      lis = ''
      messages.each do |msg|
        lis += content_tag(:li, msg)
      end
      ret = content_tag(:ul, lis, {:class => css_class})
    elsif not messages.blank?
      ret = content_tag(:div, messages, {:class => css_class})
    end
    return ret.html_safe
  end
end
