class CreateReviewLockings < ActiveRecord::Migration
  def self.up
    create_table :review_lockings do |t|
      t.integer  :review_id
      t.text     :reason
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :review_lockings, [:review_id]
  end

  def self.down
    drop_table :review_lockings
  end
end
