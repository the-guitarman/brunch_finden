class CreateUser < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :location_id
      t.string  :name
      t.string  :email
      t.boolean :general_terms_and_conditions_confirmed
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
