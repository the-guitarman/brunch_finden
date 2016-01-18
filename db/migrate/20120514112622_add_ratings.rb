class AddRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.integer  :review_id
      t.integer  :question_id
      t.integer  :value, :precision => 3, :scale => 2, :default => 0.00
    end
    
    add_index :ratings, :review_id
  end

  def self.down
    drop_table :ratings
  end
end
