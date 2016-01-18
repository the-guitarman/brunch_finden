class AddTimeStampFieldsToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :created_at, :datetime
    add_column :coupons, :updated_at, :datetime
  end

  def self.down
    remove_column :coupons, :created_at
    remove_column :coupons, :updated_at
  end
end
