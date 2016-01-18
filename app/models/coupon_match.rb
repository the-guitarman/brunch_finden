class CouponMatch < ActiveRecord::Base
#  replicated_model
  belongs_to :coupon
  belongs_to :destination, :polymorphic => true
end
