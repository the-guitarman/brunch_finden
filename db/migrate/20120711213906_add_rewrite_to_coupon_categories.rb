class AddRewriteToCouponCategories < ActiveRecord::Migration
  def self.up
    add_column :coupon_categories, :rewrite, :string
    add_index :coupon_categories, :rewrite
    CouponCategory.all.each{|cc| cc.save}
  end

  def self.down
    remove_column :coupon_categories, :rewrite
  end
end
