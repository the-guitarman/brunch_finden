class RemoveDescriptionFromCoupons < ActiveRecord::Migration
  def self.up
    remove_column :coupons, :description
  end

  def self.down
    add_column :coupons, :description, :text
  end
end
