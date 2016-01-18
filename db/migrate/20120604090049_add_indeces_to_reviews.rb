class AddIndecesToReviews < ActiveRecord::Migration
  def self.up
    add_index :reviews, :frontend_user_id
    add_index :reviews, :confirmation_code
  end

  def self.down
    remove_index :reviews, :confirmation_code
    remove_index :reviews, :frontend_user_id
  end
end
