class ChangeAggregatedRatings < ActiveRecord::Migration
  def self.up
    drop_table :aggregated_ratings

    create_table :aggregated_ratings do |t|
      t.integer  :review_question_id
      t.integer  :destination_id
      t.string   :destination_type
      t.decimal  :value, :precision => 3, :scale => 2
      t.integer  :user_count
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :aggregated_ratings, :review_question_id
    add_index :aggregated_ratings, [:destination_id, :destination_type]
  end

  def self.down
    drop_table :aggregated_ratings
    
    create_table :aggregated_ratings do |t|
      t.integer :location_id
      t.integer :question_id
      t.integer :value, :default => 0
      t.integer :user_count
    end

    add_index :aggregated_ratings, :location_id
  end
end
