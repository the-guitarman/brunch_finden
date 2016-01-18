class AddDeltaColumns < ActiveRecord::Migration
  def self.up
    add_column :cities, :delta, :integer, :default => 1, :null => false
    add_column :locations, :delta, :integer, :default => 1, :null => false
    add_column :states, :delta, :integer, :default => 1, :null => false
    add_column :zip_codes, :delta, :integer, :default => 1, :null => false
  end

  def self.down
    remove_column :zip_codes, :delta
    remove_column :states, :delta
    remove_column :locations, :delta
    remove_column :cities, :delta
  end
end
