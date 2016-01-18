class AddRewrites < ActiveRecord::Migration
  def self.up
    add_column :states, :rewrite, :string
    add_column :cities, :rewrite, :string
    add_column :locations, :rewrite, :string
  end

  def self.down
    remove_column :locations, :rewrite, :string
    remove_column :cities, :rewrite, :string
    remove_column :states, :rewrite, :string
  end
end
