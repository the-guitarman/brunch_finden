class CreateCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons do |t|
      t.integer  :data_source_id
      t.integer  :coupon_id
      t.string   :name
      t.datetime :valid_from
      t.datetime :valid_to
      t.text     :image_url,         :limit => 2147483647
      t.string   :merchant_name
      t.text     :merchant_logo_url, :limit => 2147483647
      t.text     :url,               :limit => 2147483647
      t.integer  :kind
      t.string   :hint
      t.text     :description
      t.boolean  :favourite
      t.string   :code
      t.integer  :priority
    end
    
    add_index :coupons, :coupon_id
    
    create_table :coupon_categories do |t|
      t.string :name
    end
    
    create_table :coupons_in_categories, :id => false do |t|
      t.integer :coupon_id
      t.integer :coupon_category_id
    end
    
    add_index :coupons_in_categories, [:coupon_id, :coupon_category_id]
  end

  def self.down
    drop_table :coupons_in_categories
    drop_table :coupon_categories
    drop_table :coupons
  end
end
