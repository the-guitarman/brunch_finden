class AddUpdatedAtToCouponCategories < ActiveRecord::Migration
  def self.up
    add_column :coupon_categories, :updated_at, :datetime
    execute("UPDATE coupon_categories SET updated_at = '#{Time.now.to_s(:db)}'")
  end

  def self.down
    remove_column :coupon_categories, :updated_at
  end
end
