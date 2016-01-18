class ChangeReviewsUserToFrontendUser < ActiveRecord::Migration
  def self.up
    rename_column :reviews, :user_id, :frontend_user_id
  end

  def self.down
    rename_column :reviews, :frontend_user_id, :user_id
  end
end
