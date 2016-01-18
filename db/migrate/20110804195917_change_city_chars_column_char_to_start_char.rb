class ChangeCityCharsColumnCharToStartChar < ActiveRecord::Migration
  def self.up
    rename_column :city_chars, :char, :start_char
  end

  def self.down
    rename_column :city_chars, :start_char, :char
  end
end
