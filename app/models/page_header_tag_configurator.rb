#encoding: UTF-8

# @api private
# 
# The PageHeaderTagConfigurator class helps to create and modify the title and 
# meta (description, keywords, robots) values for a webpage. 
# It returns a hash, which can be used in the application layout as described below. 
# 
# ==Usage:
# 
# * Standard Controller
#   before_filter :set_page_header_tags
#   
#   def set_page_header_tags
#     @page_header_tags_configurator = PageHeaderTagConfigurator.new(controller.last, params[:action])
#     @page_header_tags = @page_header_tags_configurator.page_header_tags
#   end
#   
# * Print It Into The Application Layout Header
#   <head>
#	    <% unless @page_header_tags.blank? -%>
#	      <title><%= @page_header_tags['title'] -%></title>
#       <% if @page_header_tags.has_key?('meta') -%>
#	        <% @page_header_tags['meta'].keys.each do |key| -%>
#           <meta name="<%= key -%>" content="<%=@page_header_tags['meta'][key] -%>" />
#	        <% end -%>
#       <% end -%>
#	    <% end -%>
#	  </head>
#
class PageHeaderTagConfigurator
  if Rails.version >= '3.0.0'
    include Rails.application.routes.url_helpers
  else
    include ActionController::UrlWriter
  end
  
  include RequestParameters
  
  include RewriteRoutes
  #include ActionView::Helpers::NumberHelper
  
  def initialize(controller, options={})
    default_url_options[:host] = controller.instance_variable_get(:@host_full_name)
    @controller = controller
    @params = @controller.params
    @controller_name = @controller.controller_name
    @action_name = @controller.action_name
    @cch = CustomConfigHandler.instance
    @options = check_options(options)
    @page_header_tags_hash = load_header_tags_from_config_file
    @page_header_tags_hash = add_current_page(@page_header_tags_hash)
    @page_header_tags_hash = add_mobile_flag(@page_header_tags_hash)
  end
  
#  def initialize(controller_name, action_name, options={})
#    fec = CustomConfigHandler.instance.frontend_config
#    default_url_options[:host] = fec['DOMAIN']['FULL_NAME']
#    
#    @controller_name = controller_name
#    @action_name = action_name
#    @options = check_options(options)
#    @page_header_tags_hash = load_header_tags_from_config_file
#  end
  
  def set_error(status_code)
    @page_header_tags_hash = {
      'title' => (I18n.t("frontend.errors.show.error_#{status_code}") rescue 'An unknown error occured.'),
      'meta'  => {
        'description' => '',
        'keywords' => '',
        'robots' => 'noindex, noarchive, nofollow'
      }
    }
  end
  
  def set_state(state)
    if city_char = @controller.instance_variable_get(:@city_char)
      canonical_href = state_rewrite_url(create_rewrite_hash(state.rewrite).merge({
        city_char_parameter => city_char.start_char.upcase})
      )
    else
      canonical_href = state_rewrite_url(create_rewrite_hash(state.rewrite))
    end
    add_header_link_tag({:rel => :canonical, :href => canonical_href})
    block = Proc.new{|value| set_state_variables(value, state)}
    @page_header_tags_hash = set_variables(@page_header_tags_hash, block)
  end
  
  def set_city(city)
    #unless @controller.request.query_string.blank?
      add_header_link_tag({
        :rel => :canonical, 
        :href => city_rewrite_url(create_rewrite_hash(city.rewrite))
      })
    #end
    block = Proc.new{|value| set_city_variables(value, city)}
    @page_header_tags_hash = set_variables(@page_header_tags_hash, block)
    block = Proc.new{|value| set_state_variables(value, city.state)}
    @page_header_tags_hash = set_variables(@page_header_tags_hash, block)
    if city.number_of_locations <= 0
      @page_header_tags_hash['meta']['robots'] = 'noindex,noarchive,follow'
    end
    @page_header_tags_hash
  end
  
  def set_location(location)
    #unless @controller.request.query_string.blank?
      add_header_link_tag({
        :rel => :canonical, 
        :href => location_rewrite_url(create_rewrite_hash(location.rewrite))
      })
    #end
    block = Proc.new{|value| set_location_variables(value, location)}
    @page_header_tags_hash = set_variables(@page_header_tags_hash, block)
    block = Proc.new{|value| set_city_variables(value, location.zip_code.city)}
    @page_header_tags_hash = set_variables(@page_header_tags_hash, block)
    block = Proc.new{|value| set_state_variables(value, location.zip_code.city.state)}
    @page_header_tags_hash = set_variables(@page_header_tags_hash, block)
  end
  
  def set_coupon_category
    coupon_category = @controller.instance_variable_get(:@coupon_category)
    coupons = @controller.instance_variable_get(:@coupons)
    page = @controller.instance_variable_get(:@page)
    #unless @controller.request.query_string.blank?
      parameters = {:rewrite => coupon_category.rewrite}
      parameters.merge!({:page => page}) if page.to_i > 1
      add_header_link_tag({:rel => :canonical, :href => coupon_category_url(parameters)})
    #end
    if coupons.length == 0
      @page_header_tags_hash['meta']['robots'] = 'noindex, noarchive, follow' 
    end
    block = Proc.new{|value| set_coupon_category_variables(value, coupon_category)}
    @page_header_tags_hash = set_variables(@page_header_tags_hash, block)
  end
  
  def set_coupon(coupon, coupon_merchant)
    #unless @controller.request.query_string.blank?
      add_header_link_tag({
        :rel => :canonical, 
        :href => coupon_url({:id => coupon.id})
      })
    #end
    block = Proc.new do |value| 
      set_coupon_variables(value, coupon)
      set_coupon_merchant_variables(value, coupon_merchant)
    end
    @page_header_tags_hash = set_variables(@page_header_tags_hash, block)
  end
  
  def set_all_coupon_merchants
    #unless @controller.request.query_string.blank?
      add_header_link_tag({:rel => :canonical, :href => all_coupon_merchants_url})
    #end
  end
  
  def set_all_merchant_coupons
    coupon_merchant = @controller.instance_variable_get(:@coupon_merchant)
    merchant_coupons = @controller.instance_variable_get(:@merchant_coupons)
    page = @controller.instance_variable_get(:@page)
    #unless @controller.request.query_string.blank?
      parameters = {:merchant_id => coupon_merchant.merchant_id}
      parameters.merge!({:page => page}) if page.to_i > 1
      add_header_link_tag({:rel => :canonical, :href => merchant_coupons_url(parameters)})
    #end
    if merchant_coupons.length == 0
      @page_header_tags_hash['meta']['robots'] = 'noindex, noarchive, follow' 
    end
    block = Proc.new{|value| set_coupon_merchant_variables(value, coupon_merchant)}
    @page_header_tags_hash = set_variables(@page_header_tags_hash, block)
  end
  
  def page_header_tags
    block = Proc.new{|value| set_standard_variables(value)}
    @page_header_tags_hash = set_variables(@page_header_tags_hash, block)
    return @page_header_tags_hash
  end
  
  private
  
  def add_current_page(page_header_tags_hash)
    page = @controller.page
    if page and page > 1
      translation = I18n.translate('shared.page')
      if page_header_tags_hash['title']
        page_header_tags_hash['title'] += " - #{translation} #{page}"
      end
      if page_header_tags_hash['meta'] and page_header_tags_hash['meta']['description']
        page_header_tags_hash['meta']['description'] += " - #{translation} #{page}"
      end
    end
    return page_header_tags_hash
  end
  
  def add_mobile_flag(page_header_tags_hash)
    if ((@controller.respond_to?(:mobile_device?) or 
        @controller.respond_to?('mobile_device')) and @controller.mobile_device?)
      if page_header_tags_hash['title']
        page_header_tags_hash['title'] += " - mobile version"
      end
      if page_header_tags_hash['meta'] and page_header_tags_hash['meta']['description']
        page_header_tags_hash['meta']['description'] += " - mobile version"
      end
    end
    return page_header_tags_hash
  end
  
  def check_options(options)
    fec = @cch.frontend_config
    if options[:host_name].blank?
      options[:host_name] = fec['DOMAIN']['NAME']
      if options[:host_name].blank?
        raise ArgumentError, 'Missing :host_name key in options.' 
      end
    end
    if options[:host_full_name].blank?
      options[:host_full_name] = fec['DOMAIN']['FULL_NAME']
      if options[:host_full_name].blank?
        raise ArgumentError, 'Missing :host_full_name key in options.' 
      end
    end
    return options
  end
  
  def load_header_tags_from_config_file
    fhdc = nil
    class_name = @controller.class.name
    if class_name.start_with?('Frontend::')
      fhdc = @cch.frontend_header_data_config
    elsif class_name.start_with?('Mobile::')
      fhdc = @cch.frontend_header_data_config
    end
    if fhdc.instance_of?(Hash) and
       fhdc[@controller_name].instance_of?(Hash) and
       fhdc[@controller_name][@action_name].instance_of?(Hash)
      ret = fhdc[@controller_name][@action_name]
    else
      ret = load_header_tag_defaults
    end
    return ret
  end
  
  def load_header_tag_defaults
    ret = {}
    class_name = @controller.class.name
    translation_key = 'page_header_tags.defaults.'
    translation_key += class_name.split('::').first.underscore + '.'
    write_tags_proc = Proc.new do |t_key, options|
      {
        'title' => I18n.t("#{t_key}title", {:domain_name => options[:host_name].to_s}),
        'meta'  => {
          'description' => I18n.t("#{t_key}description", {:domain_name => options[:host_name].to_s}),
          'keywords'    => I18n.t("#{t_key}keywords"),
          'robots'      => 'index, follow'
        }
      }
    end
    
    if class_name.start_with?('Frontend::')
      if @controller.respond_to?(:logged_in?) and 
         @controller.logged_in? and 
         class_name.start_with?('Frontend::Community')
        translation_key += 'logged_in.'
      else
        translation_key += 'logged_out.'
      end
      ret = write_tags_proc.call(translation_key, @options)
      
    elsif class_name.start_with?('Mobile::')
      if @controller.logged_in?
        translation_key += 'logged_in.'
      else
        translation_key += 'logged_out.'
      end
      ret = write_tags_proc.call(translation_key, @options)
      
    elsif class_name.start_with?('Backend::')
      # please have a look to: 
      # - app/views/layouts/backend/login.html.erb
      # - app/views/backend/_title_and_description.html.erb
      
    end
    return ret
  end
  
  def set_variables(page_header_tags_hash, block)
    page_header_tags_hash.each do |key, value|
      if value.is_a?(String)
        block.call(value)
        
        # checks for empty keywords, because of empty string replacements
        # prevents: 'keyword1, keyword2, , keyword4'
        if key.to_sym == :keywords
          values = value.split(',')
          values.map!{|v| v.strip}
          values.delete_if{|v| v.blank?}
          value = values.join(', ').downcase
        end
        value.strip!
        value.gsub!(/ {2,}/, ' ')
        value = value #.html_safe
        
      elsif value.is_a?(Hash)
        set_variables(value, block)
      end
    end
    return page_header_tags_hash
  end
  
  def set_standard_variables(value)
    value.gsub!('__DOMAIN_FULL_NAME__', @options[:host_full_name])
    value.gsub!('__DOMAIN_NAME__', @options[:host_name])
    if value.include?('__NUMBER_OF_LOCATIONS__')
      count = Location.showable.count.to_s
      number = count.first.ljust(count.length, '0')
      value.gsub!('__NUMBER_OF_LOCATIONS__', number)
    end
  end
  
  def set_state_variables(value, state)
    additional_text = ''
    if city_char = @controller.instance_variable_get(:@city_char)
      additional_text = " (#{I18n.t('page_header_tags.states.title_addition', {:start_char => city_char.start_char.upcase})})"
    end
    value.gsub!('__STATE_NAME__', state.name + additional_text)
    value.gsub!('__NUMBER_OF_LOCATIONS__', state.number_of_locations.to_s)    
    value.gsub!('__NUMBER_OF_LOCATIONS_WITH_MODEL__', "#{state.number_of_locations} #{Location.human_name({:count => state.number_of_locations})}")
  end
  
  def set_city_variables(value, city)
    value.gsub!('__CITY_NAME__', city.name)
    value.gsub!('__NUMBER_OF_LOCATIONS__', city.number_of_locations.to_s)    
    value.gsub!('__NUMBER_OF_LOCATIONS_WITH_MODEL__', "#{city.number_of_locations} #{Location.human_name({:count => city.number_of_locations})}")
  end
  
  def set_location_variables(value, location)
    value.gsub!('__LOCATION_NAME__', location.name)
  end
  
  def set_coupon_category_variables(value, coupon_category)
    value.gsub!('__COUPON_CATEGORY_NAME__', coupon_category.name)
  end
  
  def set_coupon_variables(value, coupon)
    value.gsub!('__COUPON_ID__', coupon.id.to_s)
    value.gsub!('__COUPON_NAME__', coupon.name)
    if coupon.only_new_customer == true
      value.gsub!('__ONLY_NEW_CUSTOMER__', "(#{Coupon.human_attribute_name(:only_new_customer)})")  
    else
      value.gsub!('__ONLY_NEW_CUSTOMER__', '')
    end    
  end
  
  def set_coupon_merchant_variables(value, coupon_merchant)
    value.gsub!('__MERCHANT_NAME__', coupon_merchant.name)
    value.gsub!('__NUMBER_OF_COUPONS__', coupon_merchant.number_of_coupons.to_s)
  end
  
  def add_header_link_tag(attributes)
    @page_header_tags_hash['link'] = [] if @page_header_tags_hash['link'].blank?
    @page_header_tags_hash['link'] << create_header_link_tag(attributes)
  end
  
  def create_header_link_tag(attributes)
    return ActionController::Base.helpers.tag(:link, attributes)
  end
end