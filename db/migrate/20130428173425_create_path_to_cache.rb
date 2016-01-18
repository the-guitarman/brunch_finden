class CreatePathToCache < ActiveRecord::Migration
  def self.up
    create_table :path_to_cache do |t|
      t.integer  :expired_count, :default => 1
      t.datetime :expired_last
      t.string   :path
    end
    
    add_index :path_to_cache, :path
  end

  def self.down
    drop_table :path_to_cache
  end
end
