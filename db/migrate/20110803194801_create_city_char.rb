class CreateCityChar < ActiveRecord::Migration
  def self.up
    create_table :city_chars do |t|
      t.integer :state_id
      t.string  :char, :limit => 1
      t.integer :number_of_locations, :default => 0
    end
    
    add_column :cities, :city_char_id, :integer
  end

  def self.down
    remove_column :cities, :city_char_id
    
    drop_table :city_chars
  end
end
