class CreateCouponMatches < ActiveRecord::Migration
  def self.up
    create_table :coupon_matches do |t|
      t.integer  :coupon_id
      t.integer  :destination_id
      t.string   :destination_type
      t.datetime :created_at
    end
    
    add_index :coupon_matches, :destination_type
  end

  def self.down
    drop_table :coupon_matches
  end
end
