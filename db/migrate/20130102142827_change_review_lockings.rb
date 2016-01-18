class ChangeReviewLockings < ActiveRecord::Migration
  def self.up
    remove_column :review_lockings, :reason
    add_column :review_lockings, :reason, :text
  end

  def self.down
  end
end
