class AddPublishedFlagToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :published, :boolean, :default => false
  end

  def self.down
    add_column :locations, :published
  end
end
