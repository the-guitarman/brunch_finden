class ChangeLocationIdToPolimorphDestination < ActiveRecord::Migration
  def self.up
    remove_index :aggregated_reviews, :location_id
    rename_column :aggregated_reviews, :location_id, :destination_id
    add_column :aggregated_reviews, :destination_type, :string, :after => :destination_id
    add_index :aggregated_reviews, [:destination_id, :destination_type]
    
    remove_index :aggregated_ratings, :location_id
    rename_column :aggregated_ratings, :location_id, :destination_id
    add_column :aggregated_ratings, :destination_type, :string, :after => :destination_id
    add_index :aggregated_ratings, [:destination_id, :destination_type]
  end

  def self.down
    remove_index :aggregated_ratings, [:destination_id, :destination_type]
    remove_column :aggregated_ratings, :destination_type
    rename_column :aggregated_ratings, :destination_id, :location_id
    add_index :aggregated_ratings, :location_id
    
    remove_index :aggregated_reviews, [:destination_id, :destination_type]
    remove_column :aggregated_reviews, :destination_type
    rename_column :aggregated_reviews, :destination_id, :location_id
    add_index :aggregated_reviews, :location_id
  end
end
