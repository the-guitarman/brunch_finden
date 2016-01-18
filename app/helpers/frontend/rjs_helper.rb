module Frontend::RjsHelper
  def remove_messages_below(node_id)
    id = get_clean_css_id(node_id)
    ret = remove_form_entry_error_below(node_id) +
          "$('##{id} .infobox').remove();" +
          #remove_tooltips_below(node_id) +
          "$('##{id} .text-message').remove();"
    return ret
  end
  
  def remove_form_entry_error_below(node_id)
    return "$('##{get_clean_css_id(node_id)} .form-entry.error').removeClass('error');"
  end
  
  def remove_tooltips_below(node_id)
    return "$('##{get_clean_css_id(node_id)} .form-entry > .tooltip').remove();"
  end
  
  def scroll_to_first_error(node_id)
    id = get_clean_css_id(node_id)
    return "simpleScrollTo('##{id} .infobox.error, ##{id} .form-entry.error, ##{id} .text-message.error');"
  end
  
  def append_message_to(node_id, message, type = '', options = {})
    ret = "var field = $('##{get_clean_css_id(node_id)}');
           if (field.length > 0) {
               var parents = field.parents('.form-entry');
               if (parents.length > 0) {
                   var parent = parents.first();
                   if (parent.length > 0) {
                       if ('#{type}'.length > 0 && !parent.hasClass('#{type}')) {
                           parent.addClass('#{type}');
                       }
                       if (#{(options[:append] == true ? 'false && ' : '')}field.is(':visible')) {
                           field.after('#{escape_javascript(message)}');
                       } else {
                           parent.append('#{escape_javascript(message)}');
                       }
                   }
                   delete parent;
               }
               delete parents;
           }
           delete field;
    "
    return ret.html_safe
  end
  
  def append_error_message_to(node_id, message, options = {})
    append_message_to(node_id, message, :error, options)
  end
  
  def remove_error_message_from(node_id)
    ret = "
        var ct = $('##{get_clean_css_id(node_id)}').closest('.form-entry');
        ct.removeClass('error');
        ct.find('.text-message').remove();
    "
    return ret.html_safe
  end
  
  def prepend_message_to(node_id, message)
    return "$('##{get_clean_css_id(node_id)}').prepend('#{escape_javascript(message)}');"
  end
  
  def checkbox_enable(node_id)
    ret = "var checkbox = $('##{get_clean_css_id(node_id)}');
           if (checkbox.length > 0) {
               checkbox.removeAttr('disabled');
               checkbox.parentsUntil('.checkbox-wrapper').parent().removeClass('disabled');
           }
           delete checkbox;"
    return ret
  end
  
  def checkbox_disable(node_id)
    ret = "var checkbox = $('##{get_clean_css_id(node_id)}');
           if (checkbox.length > 0) {
               checkbox.attr('disabled', 'disabled');
               checkbox.parentsUntil('.checkbox-wrapper').parent().addClass('disabled');
           }
           delete checkbox;"
    return ret
  end
  
  def checkbox_check(node_id)
    ret = "var checkbox = $('##{get_clean_css_id(node_id)}');
           if (checkbox.length > 0) {
               checkbox.attr('checked', 'checked');
               checkbox.parentsUntil('.checkbox-wrapper').parent().addClass('checked');
           }
           delete checkbox;"
    return ret
  end
  
  def checkbox_uncheck(node_id)
    ret = "var checkbox = $('##{get_clean_css_id(node_id)}');
           if (checkbox.length > 0) {
               checkbox.removeAttr('checked');
               checkbox.parentsUntil('.checkbox-wrapper').parent().removeClass('checked');
           }
           delete checkbox;"
    return ret
  end
  
  def radio_button_check(node_name, node_value)
    ret = "var noPaymentMethodCheckbox = $('input[type=radio][name=\"#{node_name}\"][value=#{node_value}]');
           noPaymentMethodCheckbox.attr('checked', 'checked');
           noPaymentMethodCheckbox.parentsUntil('.radio-button-wrapper').parent().addClass('checked');
           delete noPaymentMethodCheckbox;"
    return ret
  end
  
  def radio_button_uncheck(node_name)
    ret = "var checkboxes = $('input[type=radio][name=\"#{node_name}\"]');
           checkboxes.removeAttr('checked');
           checkboxes.parentsUntil('.radio-button-wrapper').parent().removeClass('checked');
           delete checkboxes;"
    return ret
  end
  
  def append_hidden_field(node_id, node_name, append_to_id, value)
    ret = "
        var field = $('##{get_clean_css_id(node_id)}');
        if (field.length == 0) {
            $('##{get_clean_css_id(append_to_id)}').append('#{escape_javascript(hidden_field_tag(node_name, value, :id => node_id))}');
        } else {
            field.val('#{value}');
        }
        delete field;"
    return ret
  end
  
  def slide_remove_element(css_id)
    ret = "var elements = $('##{get_clean_css_id(css_id)}');"
    ret += slide_remove
    return ret
  end
  
  def slide_remove_elements(css_class)
    ret = "var elements = $('.#{get_clean_css_class(css_class)}');"
    ret += slide_remove
    return ret
  end
  
  def hide_form_entry(css_id)
    show_or_hide_form_entry(css_id, :hide)
  end
  
  def show_form_entry(css_id)
    show_or_hide_form_entry(css_id, :show)
  end
  
  def empty_form_entries(css_id)
    id = get_clean_css_id(css_id)
    ret = "
        $('.form-entry').removeClass('checked');

        $('##{id}').find('input[type=text],input[type=password],input[type=file]').val('');
        $('##{id}').find('input[type=radio],input[type=checkbox]').removeAttr('checked');
        // TODO: reset the wrappers

        $('##{id} textarea').val('');
        $('##{id} .transformed-select').trigger('reset');"
    
    return ret
  end
  
  def observe_field(node_Id, options = {})
    with_option = options.delete(:with)
    if with_option.is_a?(Symbol)
      with_option = "{'#{with_option || node_Id}': value}"
    end
    
    ret = "
        $('##{get_clean_css_id(node_Id)}').bind('change', function(){
            var self = $(this);
            var value = self.val().trim();
            var data = #{with_option};
            #{options.delete(:before)}
            $.ajax({
                type: 'GET',
                cache: true,
                url: '#{options.delete(:url)}',
                data: data,
                //contentType: 'application/html; charset=utf-8', 
                //dataType: 'html',
                success: function(response, status, xhr) {
                    var ct = xhr.getResponseHeader('content-type') || '';
                    if (ct.indexOf('html') > -1) {
                        // handle html here
                        $('##{options.delete(:update)}').html(response);
                    } else if (ct.indexOf('json') > -1) {
                        // handle json here
                        //console.log('json returned');
                    } else {
                        //console.log('other returned');
                    }
                    #{options.delete(:success)}
                },
                error: function(xhr, ajaxOptions, thrownError) {
                    #{options.delete(:error)}
                },
                complete: function (xhr, status) {
                    if (status === 'error' || !xhr.responseText) {
                        // handler error
                    } else {
                        #{options.delete(:complete)}
                    }
                }
            });
        });
    "
    return ret.html_safe
  end
  
  def before_observe_field(css_id, default_error_message)
    ret = 
        "var field = $('##{get_clean_css_id(css_id)}');" +
        _check_asterisk_field(css_id, default_error_message) +
        add_class_to(css_id, 'loading')
    return ret.html_safe
  end
  
  def complete_observe_field(css_id)
    ret = remove_class_from(css_id, 'loading')
    return ret.html_safe
  end
  
  def check_asterisk_field(css_id, default_error_message, checked_mark = false, options = {})
    ret = "
        $('##{get_clean_css_id(css_id)}').live('#{(options[:events] ? options[:events] : 'blur')}', function() {
            var field = $(this);
            #{_check_asterisk_field(css_id, default_error_message, checked_mark, options)}
        });
    "
    return ret.html_safe
  end
  
  def check_file_field(css_id, blank_error_message, invalid_error_message, checked_mark = false, options = {})
    ret = "
        $('##{get_clean_css_id(css_id)}').live('#{(options[:events] ? options[:events] : 'blur')}', function() {
            var field = $(this);
            #{_check_asterisk_field(css_id, blank_error_message, checked_mark, options)}
            var value = field.val().trim();
            if (value.length > 0) {
                if (!value.match(/\.(jpg|png|gif)$/)) {
                    #{add_class_to(css_id, 'error')}
                    #{append_error_message_to(css_id, text_message_error(invalid_error_message), options)}
                    return false;                    
                }
            }
        });
    "
    return ret.html_safe
  end
  
  def focus_first_empty_field_within(node_id)
    ret = "
        var fields = $('##{get_clean_css_id(node_id)}').find('input[type=text],input[type=password],textarea');
        var focusField = fields.first();
        fields.each(function(idx, el){
            if ($(el).val().trim() == '') {
                focusField = $(el);
                return false;
            }
        });
        focusField.delay(400).focus();
    "
    return ret.html_safe
  end
  
  private
  
  def _check_asterisk_field(css_id, default_error_message, checked_mark = false, options = {})
    ret = "
        var missFieldValue = false;
        if (field.filter('input[type=checkbox]').length > 0) {
            missFieldValue = field.attr('checked') != 'checked';
        } else {
            missFieldValue = field.val().trim().length == 0;
        }
        var hasCheckedClass = field.closest('.form-entry').hasClass('checked');
        #{remove_class_from(css_id, 'checked', 'error')}
        #{remove_error_message_from(css_id)}
        if (missFieldValue == true) {
            #{add_class_to(css_id, 'error')}
            #{append_error_message_to(css_id, text_message_error(default_error_message), options)}
            return false;
        } else if (#{checked_mark} || hasCheckedClass) {
            #{add_class_to(css_id, 'checked')}
        }
    "
    return ret.html_safe
  end
  
  def get_clean_css_id(node_id)
    raise ArgumentError, 'The node_id can not be blank.' if node_id.blank?
    # remove leading hash and escape dot within the id
    return node_id.to_s.gsub(/^#/, '').gsub('.', '\\\\\\.')
  end
  
  def get_clean_css_class(css_class)
    raise ArgumentError, 'The css_class can not be blank.' if css_class.blank?
    return css_class.to_s.gsub(/^\./, '')
  end
  
  def slide_remove
    ret = "
        if (elements.length > 0) {
            elements.slideUp('slow', function() {
                elements.remove();
                delete elements;
            });
        } else {
            elements.remove();
            delete elements;
        }
    "
    return ret.html_safe
  end
  
  def show_or_hide_form_entry(css_id, action)
    ret = "
        var field = $('##{get_clean_css_id(css_id)}');
        if (field.length > 0) {
            var parents = field.parents('.form-entry');
            if (parents.length > 0) {
                var parent = parents.first();
                if (parent.length > 0) {
                    #{action == :show ? "parent.slideDown('slow');" : "parent.slideUp('slow');"}
                }
                delete parent;
            }
            delete parents;
        }
        delete field;
    "
    return ret.html_safe
  end
  
  def add_check_mark_to(css_id)
    return add_class_to(css_id, 'checked')
  end
  
  def remove_check_mark_from(css_id)
    return remove_class_from(css_id, 'checked')
  end
  
  def add_class_to(css_id, *css_klasses)
    ret = "$('##{get_clean_css_id(css_id)}').closest('.form-entry')"
    ret += css_klasses.map{|k| ".addClass('#{k}')"}.join 
    ret += ';'
    return ret.html_safe
  end
  
  def remove_class_from(css_id, *css_klasses)
    ret = "$('##{get_clean_css_id(css_id)}').closest('.form-entry')"
    ret += css_klasses.map{|k| ".removeClass('#{k}')"}.join 
    ret += ';'
    return ret.html_safe
  end
  
  def append_suggestions(options)
    css_id = options[:css_id]
    node_name = css_id.to_s.camelize
    content_for :jquery_global, "
        var cache#{node_name}Suggestion = {}, last#{node_name}SuggestionsXhr;"
    jquery_on_ready = " 
        $('##{get_clean_css_id(css_id)}').localSearch({
            appendTo : '#{options[:suggestion_container]}',
            html     : true,
            source   : function(request, response) {
                #{remove_class_from(css_id, 'checked')}
                
                if (last#{node_name}SuggestionsXhr) {
                    last#{node_name}SuggestionsXhr.abort();
                }

                var term = request.term;
                if (term in cache#{node_name}Suggestion) {
                    response(cache#{node_name}Suggestion[term]);
                    return;
                }
            "
            if options[:before_check]
              if term_length = options[:before_check][:length]
                jquery_on_ready += "
                if (term.length < #{term_length}) {
                    return;
                }
                "
              end
              if term_match = options[:before_check][:match]
                jquery_on_ready += "
                if (!term.match(/#{term_match}/)) {
                    return;
                }
                "
              end
            end
            if options[:update_field]
                jquery_on_ready += "
                request['update_field'] = '#{options[:update_field]}';
                request['update_value'] = '#{options[:update_value]}';
                "
            end
            jquery_on_ready += "
                #{add_class_to(css_id, 'loading')}
                last#{node_name}SuggestionsXhr = $.ajax({
                    url: '#{options[:url]}', 
                    dataType: 'json',
                    data: request,
                    success: function(data, status, xhr) {
                        cache#{node_name}Suggestion[term] = data;
                        if (xhr === last#{node_name}SuggestionsXhr) {
                            response(data);
                        }
                    },
                    complete: function(data, status, xhr){
                        #{remove_class_from(css_id, 'loading')}
                        last#{node_name}SuggestionsXhr = null;
                    }
                });
            },

            select   : function(event, ui) {
        "
        if options[:update_css_id]
          jquery_on_ready += "
              $('##{options[:update_css_id]}').val(ui.item.#{options[:update_field]});
          "
        end
        jquery_on_ready += "
                #{add_class_to(css_id, 'checked')}
                //window.location.href = ui.item.url;
                //console.debug(ui['item'])
                //console.debug(ui.item.url)
            }
        });
    "
    content_for :jquery_on_ready, jquery_on_ready
  end
  
  
end