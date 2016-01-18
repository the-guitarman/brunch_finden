class AddConfirmationCodeToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :confirmation_code, :string
  end

  def self.down
    remove_column :locations, :confirmation_code
  end
end
