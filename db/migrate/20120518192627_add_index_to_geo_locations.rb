class AddIndexToGeoLocations < ActiveRecord::Migration
  def self.up
    add_index :geo_locations, :geo_code_type
  end

  def self.down
    remove_index :geo_locations, :geo_code_type
  end
end
