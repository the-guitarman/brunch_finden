class RemoveColumnsFromCoupons < ActiveRecord::Migration
  def self.up
    remove_column :coupons, :image_url
    remove_column :coupons, :merchant_name
    remove_column :coupons, :merchant_logo_url
    
    execute('DELETE FROM coupons;')
    execute('DELETE FROM coupons_in_categories;')
    execute('DELETE FROM coupon_categories;')
    execute('DELETE FROM coupon_matches;')
    execute('DELETE FROM coupon_merchants;')
  end

  def self.down
    add_column :coupons, :image_url, :text, :limit => 2147483647
    add_column :coupons, :merchant_name, :string
    add_column :coupons, :merchant_logo_url, :text, :limit => 2147483647
  end
end
