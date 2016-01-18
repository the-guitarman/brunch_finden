class AddFaxToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :fax, :string
  end

  def self.down
    remove_column :locations, :fax
  end
end
