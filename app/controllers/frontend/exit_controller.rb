class Frontend::ExitController < Frontend::FrontendController
  def byebye
    get_exit_link
    render :text => '', :layout => 'frontend/exit'
  end

  private

  def get_exit_link
    # This short code is a test to let be needless the case-when-construct,
    # if params[:m] is a model class name like 'ShopInfo' and
    # params[:id] is a valid object id of this model and
    # params[:c] includes a valid object attribute or object method.
    # Then the object class doesn't matter, if you will need an exit link,
    # and so we would not need the case-when-construct.

    # check for model class of the requested object
    model_name = Base64.decode64(URI.decode(params[:m]))
    unless ActiveRecord::Base.check_for_model_class?(model_name)
      error_message = "ERROR: There's an invalid exit object type (#{model_name})."+
        "#{model_name} is no model class."
      Rails.logger.error(error_message)
      raise(ActiveRecord::RecordNotFound, error_message)
    end
    
    # get model class from model name and check it for inclusion of 
    # ActsAsClickoutable mixin
    model_class = model_name.constantize
    #unless model_class == Customer
      unless model_class.included_modules.include?(Mixins::ActsAsClickoutable)
        error_message = "ERROR: There's an invalid exit link. "+
          "The object does not include Mixins::ActsAsClickoutable (for: #{model_name}.find(#{params[:id]}))."
        Rails.logger.error(error_message)
        raise(NoMethodError, error_message)
      end
    #end

    # check requested object and the attribute/method to call on it
    object = model_class.find_by_id(params[:id])
    call = Base64.decode64(URI.decode(params[:c])) unless params[:c].blank?
    unless object
      error_message = "ERROR: There's an invalid exit link. "+
        "The object could not be found (for: #{model_name}.find(#{params[:id]}).#{call})."
      Rails.logger.error(error_message)
      raise(ActiveRecord::RecordNotFound, error_message)
    end

    # get exit url
    if call
      @exit_url = object.get_clickout_url(call)
    else
      @exit_url = Base64.decode64(URI.decode(params[:el]))
    end

    # raise an error, if there's no exit url
    if @exit_url.blank?
      error_message = "ERROR: There's an invalid exit link. "+
        "The attribute/method to call for the object could not be found"+
        " (for: #{model_name}.find(#{params[:id]}).get_clickout_url(#{call})."
      Rails.logger.error(error_message)
      raise(NoMethodError, error_message)
    end
    
    # track the clickout and set the (shop) name, this clickout is redirected to
    track_clickout(model_name, object)
    @redirect_to_name = redirect_to_name(object, model_name)
  end

  # Checks wether a clickout should be tracked or not.
  # Return true (yes, track it), or false (don't track it).
  def track_clickout?(model_name, object, parameters)
    # check remote ip
    # check user agent
    if not parameters[:remote_ip].blank? and
       Clickout::DO_NOT_TRACK[:ips].include?(parameters[:remote_ip])
      return false
    elsif not parameters[:user_agent].blank? and
          parameters[:user_agent].to_s.downcase.match(Clickout::DO_NOT_TRACK[:user_agents].downcase)
      return false
    end

    # Tracking limiter only for offers
    return true if model_name != 'Offers'

    # Check, wether object id saved in the session and not timed out.
    # Otherwise
    if object.respond_to?(:id)
      key = model_name.pluralize.downcase.to_sym
      ids = session[key] ||= {}
      if ids.has_key?(object.id) and ids[object.id].future?
        return false
      else
        session[key].merge!({object.id => 1.day.from_now})
      end
    end
    return true
  end

  def track_clickout(model_name, object)
    parameters = {
      :remote_ip  => request.remote_ip,
      :user_agent => request.env['HTTP_USER_AGENT']
    }
    # Check, wether clickout should be tracked or not.
    unless track_clickout?(model_name, object, parameters)
      return false
    end

    # Translate url parameters back to field names for the clickout.
    Clickout::URL_PARAMETERS.each do |field_name, url_param|
      url_param = url_param.to_s
      if field_name == 'id' or field_name.to_s.end_with?('_id')
        parameters[field_name] = params[url_param] || '0'
      else
        parameters[field_name] = params[url_param] || ''
      end
      parameters[field_name] = Base64.decode64(URI.decode(parameters[field_name]))
    end


    # Set default values, if they are not given with the url parameters
    Clickout::DEFAULT_VALUES.each do |key, value|
      if parameters[key].blank?
        parameters[key] = value
      end
    end

    # Track the destination object.
    parameters[:destination_type] = model_name
    parameters[:destination_id]   = object.id

    ## Get the shop cpc and track it,
    ## If the destination model_class is an shop or an offer.
    #if model_name == Offer.name
    #  parameters[:cpc] = object.current_cpc
    #  parameters[:product_id] = object.product_id if object.product_id?
    #  parameters[:shop_id] = object.shop_participation.shop_id
    #  parameters[:customer_id] = object.shop_participation.customer_id
    #  parameters[:shop_offer_id] = object.shop_offer_id if object.shop_offer_id?
    #  parameters[:category_path] = get_category_path(object)
    #end

    ## Customer click
    #if model_name == Customer.name
    #  parameters[:customer_id] = object.id
    #  unless parameters[:product_id].blank?
    #    product = Product.find_by_id(parameters[:product_id])
    #    parameters[:category_path] = get_category_path(product)
    #  end
    #end

    # Save the clickout.
    Clickout.create(parameters)
  end

  def redirect_to_name(object, model_name)
    ret = ''
    case model_name
    when 'Coupon'
      if object.respond_to?(:coupon_merchant) and object.coupon_merchant
        ret = object.coupon_merchant.name 
      else
        ret = Coupon.human_name
      end
    else
      ret = object.name if object.respond_to?(:name)
    end
    return ret
  end

  def get_category_path(object)
    if object.category_id?
      object.category.parents.map{|c| c.name}.join(' > ')
    else
      nil
    end
  end
end
