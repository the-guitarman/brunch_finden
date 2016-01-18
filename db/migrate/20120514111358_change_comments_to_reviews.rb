class ChangeCommentsToReviews < ActiveRecord::Migration
  def self.up
    drop_table :comments
    
    create_table :reviews do |t|
      t.integer  :location_id
      t.integer  :user_id
      t.integer  :state, :default => 0
      t.integer  :value, :precision => 3, :scale => 2, :default => 0.00
      t.integer  :helpful_yes
      t.integer  :helpful_no
      t.boolean  :general_terms_and_conditions_confirmed
      t.datetime :published_at
      t.timestamps
      t.string   :confirmation_code
      t.text     :text
    end
    
    add_index :reviews, :location_id
  end

  def self.down
    drop_table :reviews
    
    create_table :comments do |t|
      t.integer :location_id
      t.string :name
      t.string :email
      t.string :title
      t.text   :comment
      t.timestamps
    end
  end
end
