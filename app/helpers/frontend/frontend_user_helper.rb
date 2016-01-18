module Frontend::FrontendUserHelper
  def user_short(associated_item)
    FrontendUser.short.find_by_id(associated_item.frontend_user_id)
  end

  def user_short_by_id(id)
    FrontendUser.short.find_by_id(id)
  end
  
  def user_name(user)
    ret = ''
    if user && user.login?
      ret = user.login
    elsif user && user.unknown? and !user.name.blank?
      ret = user.name
    else
      ret = "(#{FrontendUser.human_attribute_name(:name)})"
    end
    return ret.html_safe
  end
end