module Frontend::CouponsHelper
  def coupon_link(coupon, track_fields = {}, options = {})
    track_fields.delete(:id)
    description = options.delete(:alt)
    #description = h("#{coupon.name.sanitize} #{coupon.coupon_merchant.name.sanitize}") if description.blank?
    description = h("#{Coupon.human_name} #{coupon.coupon_merchant.name.sanitize}") if description.blank?
    return link_to(
      image_tag(coupon.image_url, {:alt => description}.merge(options)),
      coupon_url({:id => coupon.id}.merge(track_fields)),
      {:rel => :nofollow, :title => description}
    ).html_safe
  end
  
  def coupon_merchant_link(coupon_merchant_or_coupon, options = {})
    if coupon_merchant_or_coupon.is_a?(Coupon)
      coupon_merchant = coupon_merchant_or_coupon.coupon_merchant
    else
      coupon_merchant = coupon_merchant_or_coupon
    end
    return link_to(
      get_coupon_merchant_image_tag(coupon_merchant, {:size => :small}.merge(options)),
      merchant_coupons_url({:merchant_id => coupon_merchant.merchant_id}),
      {:class => 'coupon-merchant'}
    ).html_safe
  end
  
  def remaining_days(coupon, show_only_valid_for_eq_to_or_lt_x_days = 7)
    days = distance_in_days(coupon.valid_to)
    remaining_days = I18n.t('shared.coupons.remaining_days', :count => days)
    translation_key = 'shared.coupons.'
    if show_only_valid_for_eq_to_or_lt_x_days and 
       show_only_valid_for_eq_to_or_lt_x_days >= days
      translation_key += 'only_valid_for'
    else
      translation_key += 'valid_for'
    end
    return I18n.t(translation_key, :remaining_days => remaining_days)
  end
end