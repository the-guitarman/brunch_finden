class ChangePublishedDefaultValueInLocationsAgain < ActiveRecord::Migration
  def self.up
    change_column :locations, :published, :boolean, :default => nil, :null => true
  end

  def self.down
    change_column :locations, :published, :boolean, :default => false, :null => false
  end
end
