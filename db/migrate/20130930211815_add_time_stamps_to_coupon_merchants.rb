class AddTimeStampsToCouponMerchants < ActiveRecord::Migration
  def self.up
    add_column :coupon_merchants, :updated_at, :datetime
  end

  def self.down
    remove_column :coupon_merchants, :updated_at
  end
end
