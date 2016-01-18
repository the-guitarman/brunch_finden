class AddPublishedAndConfirmationCodeToLocationImages < ActiveRecord::Migration
  def self.up
    add_column :location_images, :published, :boolean, :default => false, :after => :uploader_denied_main_image
    add_column :location_images, :confirmation_code, :string
    
    add_index :location_images, :confirmation_code
  end

  def self.down
    remove_column :location_images, :confirmation_code
    remove_column :location_images, :published
  end
end
