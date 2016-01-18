class CreateZipCodes < ActiveRecord::Migration
  def self.up
    create_table :zip_codes do |t|
      t.integer :city_id
      t.string :code, :limit => 10
    end
    add_index :zip_codes, :city_id
    add_index :zip_codes, :code
  end

  def self.down
    drop_table :zip_codes
  end
end
