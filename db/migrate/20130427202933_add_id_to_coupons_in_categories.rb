class AddIdToCouponsInCategories < ActiveRecord::Migration
  def self.up
    add_column :coupons_in_categories, :id, :primary_key, :after => :coupon_id
    move_column :coupons_in_categories, :coupon_id, :integer, :after => :id
  end

  def self.down
    remove_column :coupons_in_categories, :id
  end
end
