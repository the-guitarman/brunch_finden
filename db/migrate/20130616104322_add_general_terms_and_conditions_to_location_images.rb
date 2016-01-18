class AddGeneralTermsAndConditionsToLocationImages < ActiveRecord::Migration
  def self.up
    add_column :location_images, :general_terms_and_conditions, :boolean, :default => false, :after => :uploader_denied_main_image
  end

  def self.down
    remove_column :location_images, :general_terms_and_conditions
  end
end
