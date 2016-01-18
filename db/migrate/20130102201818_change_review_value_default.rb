class ChangeReviewValueDefault < ActiveRecord::Migration
  def self.up
    change_column :reviews, :value, :integer, :default => nil
  end

  def self.down
    change_column :reviews, :value, :integer, :default => 0
  end
end
