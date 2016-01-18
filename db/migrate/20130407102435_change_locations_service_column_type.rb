class ChangeLocationsServiceColumnType < ActiveRecord::Migration
  def self.up
    change_column :locations, :service, :text
  end

  def self.down
    change_column :locations, :service, :string
  end
end
