class AddAggregatedRatings < ActiveRecord::Migration
  def self.up
    create_table :aggregated_ratings do |t|
      t.integer :location_id
      t.integer :question_id
      t.integer :value, :precision => 3, :scale => 2, :default => 0.00
      t.integer :user_count
    end
    
    add_index :aggregated_ratings, :location_id
  end

  def self.down
    drop_table :aggregated_ratings
  end
end
