class AddCouponsToCouponCategories < ActiveRecord::Migration
  def self.up
    add_column :coupon_categories, :number_of_coupons, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :coupon_categories, :number_of_coupons
  end
end
