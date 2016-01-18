class CreateErrors < ActiveRecord::Migration
  def self.up
    create_table :errors do |t|
      t.string :message
      t.text :backtrace
      t.string :status
      
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :errors
  end
end
