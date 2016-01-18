class CreateCities < ActiveRecord::Migration
  def self.up
    create_table :cities do |t|
      t.integer :state_id
      t.string :name
    end
    add_index :cities, :state_id
    add_index :cities, :name
  end

  def self.down
    drop_table :cities
  end
end
