class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.integer :zip_code_id
      t.string  :name
      t.text    :description
      t.string  :street
      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
