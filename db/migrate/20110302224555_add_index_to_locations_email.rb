class AddIndexToLocationsEmail < ActiveRecord::Migration
  def self.up
    add_index :locations, :email
  end

  def self.down
    remove_index :locations, :email
  end
end
