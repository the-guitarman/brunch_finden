class ExtendReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :confirmation_reminders_to_send, :integer, :after => :general_terms_and_conditions
    add_column :reviews, :aggregated_rating, :integer, :after => :value
  end

  def self.down
    remove_column :reviews, :aggregated_rating
    remove_column :reviews, :confirmation_reminders_to_send
  end
end
