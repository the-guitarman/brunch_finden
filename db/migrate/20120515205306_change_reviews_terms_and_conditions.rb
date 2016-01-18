class ChangeReviewsTermsAndConditions < ActiveRecord::Migration
  def self.up
    rename_column :reviews, :general_terms_and_conditions_confirmed, :general_terms_and_conditions
  end

  def self.down
    rename_column :reviews, :general_terms_and_conditions, :general_terms_and_conditions_confirmed
  end
end
