#encoding: utf-8
require 'test_helper'

class CouponsInCategoryTest < ActiveSupport::TestCase  
  should belong_to(:coupon)
  should belong_to(:coupon_category)
end
