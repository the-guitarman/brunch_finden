class ChangeCouponHintColumnType < ActiveRecord::Migration
  def self.up
    change_column :coupons, :hint, :text
  end

  def self.down
    change_column :coupons, :hint, :string
  end
end
