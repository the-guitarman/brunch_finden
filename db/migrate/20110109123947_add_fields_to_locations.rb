class AddFieldsToLocations < ActiveRecord::Migration
  def self.up
    change_table :locations do |t|
      t.string :brunch_time
      t.string :opening_hours
      t.string :service
      t.decimal :price, :precision => 6, :scale => 2
      t.string :price_information
      t.string :phone
      t.string :email
      t.string :website
    end
  end

  def self.down
    change_table :locations do |t|
      t.remove :brunch_time
      t.remove :opening_hours
      t.remove :service
      t.remove :price
      t.remove :price_information
      t.remove :phone
      t.remove :email
      t.remove :website
    end
  end
end
