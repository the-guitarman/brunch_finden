class ExtendCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :merchant_id, :integer
    add_column :coupons, :value, :decimal, :precision => 10, :scale => 2
    add_column :coupons, :unit, :string
    add_column :coupons, :minimum_order_value, :decimal, :precision => 10, :scale => 2
    add_column :coupons, :only_new_customer, :boolean
  end

  def self.down
    remove_column :coupons, :merchant_id
    remove_column :coupons, :value
    remove_column :coupons, :unit
    remove_column :coupons, :minimum_order_value
    remove_column :coupons, :only_new_customer
  end
end
