class AddDescriptionToCouponMerchants < ActiveRecord::Migration
  def self.up
    add_column :coupon_merchants, :description, :text
  end
  
  def self.down
    remove_column :coupon_merchants, :description
  end
end
