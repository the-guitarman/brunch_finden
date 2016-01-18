class AddNotToMatchToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :not_to_match, :boolean, :default => false, :after => :merchant_id
  end
  
  def self.down
    remove_column :coupons, :not_to_match
  end
end
