class AddDescriptionToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :description, :text
  end

  def self.down
    remove_column :cities, :description
  end
end
