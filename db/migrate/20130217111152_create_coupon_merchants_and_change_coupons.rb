class CreateCouponMerchantsAndChangeCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupon_merchants do |t|
      t.integer :merchant_id
      t.integer :number_of_coupons, :default => 0
      t.string  :name
      t.text    :logo_url, :limit => 2147483647
    end
    
    add_index :coupon_merchants, :merchant_id
    
    move_column :coupons, :merchant_id, :integer, :after => :coupon_id
    add_index :coupons, :merchant_id
    add_index :coupons, :customer_id
  end

  def self.down
    remove_index :coupons, :merchant_id
    remove_index :coupons, :customer_id
    
    drop_table :coupon_merchants
  end
end
