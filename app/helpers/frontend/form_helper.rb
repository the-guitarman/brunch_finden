module Frontend::FormHelper
  def asterisk
    content_tag(:span, '<span></span>', {:class => 'asterisk'})
  end
  
  def asterisk_note
    content_tag(:span, t('shared.asterisk_note', {:image => "(#{asterisk})"}), {:class => 'asterisk-note'})
  end
  
  def price_mark
    # price to the one
    content_tag('span', '&sup1;', {:class => 'price-mark', :title => t('shared.price.changes_possible')})
  end

  def price_description
    # price to the one mark and description
    content_tag('span', t('shared.price.changes_possible'), {:class => 'price-description'})
  end

  def price_mark_description
    # price to the one description
    price_mark + ' ' + price_description
  end

  def required_field_tag
    content_tag('span', '*', {:class => 'required-field'})
  end
  
  def form_entry(field_type, form, object, field_name, options = {})
    content = ''
    container_type  = options.delete(:container_type) || :li
    container_class = options.delete(:container_class)
    base_class = object.class.respond_to?(:base_class) ? object.class.base_class : object.class
    suggestions_field_name = field_name
    errors = text_message_error(field_errors(object, field_name))
    label_classes = options.delete(:label_class).to_s.split(' ')
    label_classes.delete_if{|c| c.blank?}
    label_class   = label_classes.join(' ')
    label_options = {:class => label_class}
    label_name = base_class.human_attribute_name(options.delete(:label_name) || field_name)
    no_label = options.delete(:no_label)
    if form
      content += form.label(field_name, label_name, label_options) unless no_label
    else
      unless options.delete(:field_name_format) == :simple
        field_name = "#{base_class.name.underscore}[#{field_name}]"
        suggestions_field_name = "#{base_class.name.underscore}_#{field_name}"
      end
      content += label_tag(field_name, label_name, label_options) unless no_label
    end
    if sn = options.delete(:small_note)
      content += content_tag(:small, sn)
    end
    input = ''
    field_size  = options.delete(:field_size)
    field_class = options.delete(:field_class)
    field_classes = field_class.to_s.split(' ')
    field_classes.delete_if{|c| c.blank?}
    container_classes = container_class.to_s.split(' ')
    container_classes.delete_if{|c| c.blank?}
    if errors.blank? and (field_classes.include?('asterisk') or label_classes.include?('asterisk'))
      if object and object.respond_to?(field_name.to_sym) and object.errors[field_name.to_sym].blank? or 
        not options[:field_value].blank? and not params[field_name].blank?
        container_classes << 'checked'
      end
    end
    if field_classes.include?('asterisk')
      field_classes.delete_if{|c| c == 'asterisk'}
      field_class = asterisk_field_classes(base_class.name.underscore.to_sym, field_name.to_sym)
      field_class = field_class + ' ' + field_classes.join(' ')
    end
    field_options = {:size => field_size, :class => field_class}
    field_options[:autocomplete] = :off if options[:suggestion_options]
    container_class = container_classes.join(' ')
    case field_type.to_sym
    when :file_field
      if form
        input += form.file_field(field_name, field_options)
      else
        input += file_field_tag(field_name, field_options)
      end
    when :text_field
      if form
        input += form.text_field(field_name, field_options)
      else
        input += text_field_tag(field_name, options[:field_value] || params[field_name], field_options)
      end
    when :password_field
      if form
        input += form.password_field(field_name, field_options)
      else
        input += password_field_tag(field_name, options[:field_value] || params[field_name], field_options)
      end
    when :text_area
      field_options[:size] = "#{field_size-2}x5" if field_size
      if form
        input += form.text_area(field_name, field_options)
      else
        input += text_area_tag(field_name, options[:field_value] || params[field_name], field_options)
      end
    when :amount_field
      field_options[:size] = field_size - 30 if field_size
      if form
        input += number_to_currency(form.amount_field(field_name, field_options))
      else
        input += number_to_currency(amount_field_tag(field_name, options[:field_value] || params[field_name], field_options))
      end
    when :check_box
      if form
        input += form.check_box(field_name)
      else
        input += check_box_tag(field_name, options[:field_value] || params[field_name], options[:checked])
      end
      input += '<span class="label">' + options[:check_box_text] + '</span>' unless options[:check_box_text].blank?
    end
    input += form_entry_suggestions(form, object, suggestions_field_name, options[:suggestion_options])
    content += content_tag(:div, input.html_safe, {:class => 'input-area'})
    content += errors
    content_tag(container_type, content.html_safe, {:class => "form-entry#{form_entry_error(object, field_name)}#{container_class ? " #{container_class}" : ''}"})
  end
  
  def form_entry_suggestions(form, object, field_name, options = {})
    content = ''
    if options and not options.empty?
      content += content_tag(:div, nil, {
        :id => options[:id], :class => "#{options[:class]} local-suggestions".strip
      })
      if options[:id]
        suggestion_container = "##{options[:id]}"
      elsif options[:class]
        suggestion_container = ".#{options[:class]}"
      end
      options[:css_id] = form ? "#{object.class.name.underscore}_#{field_name}" : field_name
      options[:suggestion_container] = suggestion_container
      options[:url] = options[:url]
      if options[:update_field]
        if form
          options[:update_css_id] = "#{object.class.name.underscore}_#{options[:update_field]}"
        else
          options[:update_css_id] = options[:update_field]
        end
        options[:update_field] = options[:update_field]
        options[:update_value] = options[:update_value] || options[:update_field]
      end
      append_suggestions(options)
    end
    return content.html_safe
  end
  
  def asterisk_field_classes(*keys)
    classes = 'asterisk'
    if !params.seek(*keys).blank? and action_name == 'create'
      classes += ' checked'
    end
    return classes
  end

  def form_item_loading_icon
    image_tag('frontend/form_item_loading_21x16.gif', {:alt => ''})
  end

  def form_item_ok_icon
    image_tag('frontend/form_item_ok_21x16.png', {:alt => ''})
  end

  def form_item_error_icon
    image_tag('frontend/form_item_error_21x16.png', {:alt => ''})
  end
end