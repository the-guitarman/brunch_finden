class CouponsInCategory < ActiveRecord::Base
  if Rails.version < '3.0.0'
    set_table_name :coupons_in_categories
  else
    self.table_name = :coupons_in_categories
  end
  
  belongs_to :coupon
  belongs_to :coupon_category
end