class ChangeRatings < ActiveRecord::Migration
  def self.up
    drop_table :ratings
    
    create_table :ratings do |t|
      t.integer  :review_question_id
      t.integer  :review_id, :default => 0, :null => false
      t.decimal  :value, :precision => 3, :scale => 2
      t.string   :text
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    rop_table :ratings
    
    create_table :ratings do |t|
      t.integer :review_id
      t.integer :question_id
      t.integer :value, :default => 0
    end
  end
end
