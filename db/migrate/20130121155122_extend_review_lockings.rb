class ExtendReviewLockings < ActiveRecord::Migration
  def self.up
    add_column :review_lockings, :state, :integer, :after => :review_id
  end

  def self.down
    remove_column :review_lockings, :state
  end
end
