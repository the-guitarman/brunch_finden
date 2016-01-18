class AddParamsToErrors < ActiveRecord::Migration
  def self.up
    add_column :errors, :params, :string
  end

  def self.down
    remove_column :errors, :params
  end
end
