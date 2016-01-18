module Frontend::BreadcrumbHelper
  include RewriteRoutes
  
  def breadcrumb
    @c_name = controller_name
    @a_name = action_name
    #c_class_name = controller.class.name
    #a_name = controller.action_name
    
    path_items = [get_crumb_link('Home', root_url)]
    
    if @error_status_code.to_i >= 400
      path_items.push(get_crumb(controller_translation(:errors)))
      path_items.push(get_crumb(@error_status_code))
      return path_items.join('').html_safe
    end
    
    case @c_name
    when 'cities'
      path_items += breadcrumb_items(@city)
      
    when 'coupons'
      if @a_name == 'index'
        path_items.push(get_crumb('Gutscheine', coupons_url))
      else
        path_items.push(get_crumb_link('Gutscheine', coupons_url))
      end
      if @a_name == 'all_coupon_merchants'
        path_items.push(get_crumb('Alle Gutschein-Anbieter', all_coupon_merchants_url))
      elsif @a_name == 'all_merchant_coupons'
        path_items.push(get_crumb_link('Alle Gutschein-Anbieter', all_coupon_merchants_url))
        if coupon = @merchant_coupons.first
          path_items.push(
            get_crumb(
              "#{coupon.coupon_merchant.name} Gutscheine",
              merchant_coupons_url({:merchant_id => coupon.merchant_id})
            )
          )
        end
      end
      
    when 'coupon_categories'
      path_items.push(get_crumb_link('Gutscheine', coupons_url))
      if @a_name == 'index'
        path_items.push(get_crumb('Alle Gutschein-Kategorien', coupon_categories_url))
      elsif @a_name == 'show'
        path_items.push(get_crumb_link('Alle Gutschein-Kategorien', coupon_categories_url))
        path_items.push(get_crumb(@coupon_category.name, coupon_category_url({:rewrite => @coupon_category.rewrite})))
      end
      
    when 'errors'
      path_items.push(controller_translation)
      path_items.push(params[:id])
      
    when 'locations'
      if ['new', 'create'].include?(@a_name)
        path_items.push(controller_action_translation({:action => :new}))
      elsif @locations
        controller_action_translation({:action => @a_name})
      else
        path_items += breadcrumb_items(@location)
      end
      
    when 'location_suggestions'
      if ['new', 'create'].include?(@a_name)
        path_items.push(controller_action_translation({:action => :new}))
      else
        path_items += breadcrumb_items(@location)
      end
    
    when 'reviews'
      destination = @review.destination
      path_items += breadcrumb_items(destination)
      path_items.pop
      path_items << get_crumb_link(
        destination.name, 
        location_rewrite_url(create_rewrite_hash(destination.rewrite))
      )
      
      if ['new', 'create', 'confirm'].include?(@a_name)
        path_items.push(controller_action_translation({:action => :new}))
      end
      
    when 'states'
      current_start_char = @city_char.start_char.upcase
      state_parameters = create_rewrite_hash(@state.rewrite).merge({city_char_parameter => current_start_char})
      path_items.push(
        get_crumb(
          "#{@state.name} (#{current_start_char})", 
          state_rewrite_url(state_parameters)
        )
      )
      
    else
      #path_items.push(get_crumb(String.new(path_items.last[:name])))
      path_items.push(controller_action_translation)
      
    end
    
    path_items.flatten!
    
    # via http://data-vocabulary.org/Breadcrumb
    #ret = content_tag(:div, path_items.join('').html_safe, {
    #  :id => 'breadcrumb', :itemscope => '', :itemtype => 'http://data-vocabulary.org/Breadcrumb'
    #})

    # via http://schema.org/WebPage
    ret = content_tag(:ol, crumb_chain_node(path_items, 0), {
      :class => 'breadcrumb', :itemscope => '', :itemtype => 'http://schema.org/WebPage'
    })

    # via ?
    #ret = '<div id="breadcrumb" itemprop="breadcrumb">' + path_items.join('') + '</div>'
    
    return ret.html_safe
  end
  
  def breadcrumb_items(item)
    if item.is_a?(State)
      [get_crumb(item.name, state_rewrite_url(create_rewrite_hash(item.rewrite)))]
    elsif item.is_a?(City)
      #_breadcrumb_items(item.state) << get_crumb(item.name)
      _breadcrumb_state_item(item) << get_crumb(item.name, city_rewrite_url(create_rewrite_hash(item.rewrite)))
    elsif item.is_a?(Location)
      _breadcrumb_items(item.zip_code.city) << get_crumb(item.name, location_rewrite_url(create_rewrite_hash(item.rewrite)))
    end
  end  
  
  private
  
  def _breadcrumb_items(item)
    if item.is_a?(State)
      [get_crumb_link(item.name, state_rewrite_url(create_rewrite_hash(item.rewrite)))]
    elsif item.is_a?(City)
      #_breadcrumb_items(item.state) << get_crumb_link(item.name, city_rewrite_url(create_rewrite_hash(item.rewrite)))
      _breadcrumb_state_item(item) << get_crumb_link(item.name, city_rewrite_url(create_rewrite_hash(item.rewrite)))
    elsif item.is_a?(Location)
      _breadcrumb_items(item.zip_code.city) << get_crumb_link(item.name, location_rewrite_url(create_rewrite_hash(item.rewrite)))
    end
  end
  
  def _breadcrumb_state_item(city)
    state = city.state
    cc = city.city_char.start_char.upcase
    [get_crumb_link(
      "#{state.name} (#{cc})".html_safe, 
      state_rewrite_url(create_rewrite_hash(state.rewrite).merge({city_char_parameter => cc}))
    )]
  end

  def controller_translation(controller = nil)
    ret = nil
    if translation = (I18n.t!("shared.breadcrumb.controllers.#{(controller || @c_name)}") rescue nil)
      ret = translation
    end
    return ret
  end

  def controller_action_translation(options = {})
    controller = options.delete(:controller)
    action = options.delete(:action)
    ret = nil
    if translation = (I18n.t!("shared.breadcrumb.controller.#{(controller || @c_name)}.#{(action || params[:action])}") rescue nil)
      ret = translation
    end
    return ret
  end

  def get_crumb_link(content, url, title = nil)
    # via http://data-vocabulary.org/Breadcrumb
    #ret = content_tag(:span, content, {:itemprop => 'title'})
    #ret = link_to(ret, url, {:class => 'breadcrumb_item', :itemprop => 'url'})
    ##ret = content_tag(:span, ret, {:itemprop => 'child', :itemscope => '', :itemtype => 'http://data-vocabulary.org/Breadcrumb'})
    #return ret
    
    # via http://schema.org/WebPage
    ret = content_tag(:span, content, {:itemprop => 'text'})
    return link_to(ret, url, {:class => 'breadcrumb-item', :itemprop => 'url', :title => title})
    
    # via ?
    #return link_to(content, url, {:class => 'breadcrumb-item', :title => title, :itemprop => 'url'}).html_safe
  end
  
  def get_crumb(content, url = nil)
    # via http://data-vocabulary.org/Breadcrumb
    #ret = content_tag(:span, content, {:class => 'breadcrumb-item', :itemprop => 'title'})
    ##ret = content_tag(:span, ret, {:itemprop => 'child', :itemscope => '', :itemtype => 'http://data-vocabulary.org/Breadcrumb'})
    #return ret
    
    # via http://schema.org/WebPage
    ret = content_tag(:span, content, {:class => 'breadcrumb-item', :itemprop => 'text'})
    if url
      ret += tag(:link, {:href => url, :itemprop => 'url'})
    end
    return ret
    
    # via ?
    #return ('<span class="breadcrumb-item">' + content + '</span>').html_safe
  end

  def crumb_chain_node(crumbs, idx)
    crumb = crumbs[idx]
    return '' unless crumb
    ret = crumb + crumb_chain_node(crumbs, (idx + 1))
    ret = content_tag(:li, ret, {
      :class => (crumb == crumbs.last ? 'active' : nil),
      :itemprop => crumbs.first == crumb ? 'breadcrumb' : 'child', 
      :itemscope => '', 
      :itemtype => 'http://schema.org/breadcrumb'
    })
    return ret.html_safe
  end
end