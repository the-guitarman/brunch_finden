class LocationSuggestions < ActiveRecord::Migration
  def self.up
    create_table :location_suggestions do |t|
      t.string :name
      t.string :city
      t.text :information
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :location_suggestions
  end
end
