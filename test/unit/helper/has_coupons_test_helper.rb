# encoding: utf-8

module HasCouponsTestHelper
  def self.included(klass)
    klass.instance_eval do
      klass.class_eval do
        should have_many(:coupon_matches).dependent(:destroy)
        should have_many(:coupons)
      end
      
      extend ClassMethods
      include InstanceMethods
    end
  end
  
  module ClassMethods
    def klass_has_coupons(klass)
      cattr_accessor :klass_has_coupons
      self.klass_has_coupons = klass
    end
  end
  
  module InstanceMethods
    def test_has_coupons
      klass = self.class.klass_has_coupons
      klass.included_modules.include?(Mixins::HasCoupons)

      klass.delete_all
      object = klass.create(valid_attributes)
      #puts object.errors.inspect

      assert_equal 0, object.coupons.count
      object.coupons << Coupon.first

      object.reload
      assert_equal 1, object.coupons.count

      coupon_id = object.coupons.first.id
      coupon_match_id = object.coupon_matches.first.id

      object.destroy
      #puts object.errors.inspect
      assert object.frozen?

      assert (not Coupon.find_by_id(coupon_id).nil?)
      assert CouponMatch.find_by_id(coupon_match_id).nil?
    end
  end
end