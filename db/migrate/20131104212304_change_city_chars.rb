class ChangeCityChars < ActiveRecord::Migration
  def self.up
    change_column :city_chars, :start_char, :string, :limit => 2
  end

  def self.down
    change_column :city_chars, :start_char, :string, :limit => 1
  end
end
