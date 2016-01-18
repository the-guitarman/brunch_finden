class ChangeLocationImageDefaults < ActiveRecord::Migration
  def self.up
    change_column :location_images, :image_format, :string, :default => 'png', :limit => 10
    change_column :location_images, :status, :string, :default => 'new', :limit => 10
  end

  def self.down
    change_column :location_images, :image_format, :string, :default => :png, :limit => 10
    change_column :location_images, :status, :string, :default => :new, :limit => 10
  end
end
