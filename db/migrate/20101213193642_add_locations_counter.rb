class AddLocationsCounter < ActiveRecord::Migration
  def self.up
    add_column :states, :number_of_locations, :integer, :default => 0
    add_column :cities, :number_of_locations, :integer, :default => 0
    add_column :zip_codes, :number_of_locations, :integer, :default => 0
  end

  def self.down
    remove_column :zip_codes, :number_of_locations
    remove_column :cities, :number_of_locations
    remove_column :states, :number_of_locations
  end
end
