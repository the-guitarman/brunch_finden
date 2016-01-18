class ChangeReview < ActiveRecord::Migration
  def self.up
    remove_index :reviews, :location_id
    
    rename_column :reviews, :location_id, :destination_id
    add_column :reviews, :destination_type, :string, :after => :destination_id
    
    add_index :reviews, [:destination_id, :destination_type]
  end

  def self.down
    remove_index :reviews, [:destination_id, :destination_type]
    
    rename_column :reviews, :destination_id, :location_id
    remove_column :reviews, :destination_type
    
    add_index :reviews, :location_id
  end
end
