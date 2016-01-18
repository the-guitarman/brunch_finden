class CreateSearchSuggestions < ActiveRecord::Migration
  def self.up
    create_table :search_suggestions do |t|
      t.integer :destination_id
      t.string  :destination_type
      t.string  :phrase
      t.integer :weight
      t.string  :state
    end
    add_index :search_suggestions, :destination_type
  end

  def self.down
    drop_table :search_suggestions
  end
end
