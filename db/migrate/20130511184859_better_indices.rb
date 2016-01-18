class BetterIndices < ActiveRecord::Migration
  def self.up
    remove_index :aggregated_ratings, [:destination_id, :destination_type]
    add_index :aggregated_ratings, [:destination_type, :destination_id]
    
    remove_index :aggregated_reviews, [:destination_id, :destination_type]
    add_index :aggregated_reviews, [:destination_type, :destination_id]
    
    remove_index :coupon_matches, [:destination_id, :destination_type]
    add_index :coupon_matches, [:destination_type, :destination_id]
    
    add_index :frontend_users, :new_email
    
    remove_index :geo_locations, [:geo_code_id, :geo_code_type]
    add_index :geo_locations, [:geo_code_type, :geo_code_id]
    remove_index :geo_locations, :geo_code_type
    
    remove_index :reviews, [:destination_id, :destination_type]
    add_index :reviews, [:destination_type, :destination_id]
  end

  def self.down
    remove_index :aggregated_ratings, [:destination_type, :destination_id]
    add_index :aggregated_ratings, [:destination_id, :destination_type]
    
    remove_index :aggregated_reviews, [:destination_type, :destination_id]
    add_index :aggregated_reviews, [:destination_id, :destination_type]
    
    remove_index :coupon_matches, [:destination_type, :destination_id]
    add_index :coupon_matches, [:destination_id, :destination_type]
    
    add_index :frontend_users, :new_email
    
    remove_index :geo_locations, [:geo_code_type, :geo_code_id]
    add_index :geo_locations, [:geo_code_id, :geo_code_type]
    add_index :geo_locations, :geo_code_type
    
    remove_index :reviews, [:destination_type, :destination_id]
    add_index :reviews, [:destination_id, :destination_type]
  end
end
