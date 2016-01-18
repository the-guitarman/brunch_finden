class AddAggregatedReviews < ActiveRecord::Migration
  def self.up
    create_table :aggregated_reviews do |t|
      t.integer :location_id
      t.integer :value, :precision => 3, :scale => 2, :default => 0.00
      t.integer :user_count
      t.string  :users_per_value
    end
    
    add_index :aggregated_reviews, :location_id
  end

  def self.down
    drop_table :aggregated_reviews
  end
end
