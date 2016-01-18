class CreateGeoLocations < ActiveRecord::Migration
  def self.up
    create_table :geo_locations do |t|
      t.integer :geo_code_id
      t.string  :geo_code_type
      t.float   :lat
      t.float   :lng
    end

    add_index :geo_locations, [:geo_code_id, :geo_code_type]
    add_index :geo_locations, [:lat, :lng]
  end

  def self.down
    drop_table :geo_locations
  end
end
