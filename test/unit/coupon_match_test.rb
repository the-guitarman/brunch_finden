#encoding: utf-8
require 'test_helper'

class CouponMatchTest < ActiveSupport::TestCase
  should belong_to(:coupon)
  should belong_to(:destination)
end
