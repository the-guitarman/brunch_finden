class ChangePublishedDefaultValueInLocations < ActiveRecord::Migration
  def self.up
    change_column :locations, :published, :boolean, :default => false, :null => false
  end

  def self.down
    change_column :locations, :published, :boolean, :default => nil, :null => true
  end
end
