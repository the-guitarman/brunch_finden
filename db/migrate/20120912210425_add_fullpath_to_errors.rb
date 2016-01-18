class AddFullpathToErrors < ActiveRecord::Migration
  def self.up
    add_column :errors, :fullpath, :text
  end

  def self.down
    remove_column :errors, :fullpath
  end
end
