class AddRewriteIndexes < ActiveRecord::Migration
  def self.up
    add_index :states, :rewrite
    add_index :cities, :rewrite
    add_index :locations, :rewrite
  end

  def self.down
    remove_index :locations, :rewrite
    remove_index :cities, :rewrite
    remove_index :states, :rewrite
  end
end
