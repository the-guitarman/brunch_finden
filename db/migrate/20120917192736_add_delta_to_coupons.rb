class AddDeltaToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :delta, :integer, :default => 1, :null => false
  end

  def self.down
    remove_column :coupons, :delta
  end
end
