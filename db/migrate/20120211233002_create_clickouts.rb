class CreateClickouts < ActiveRecord::Migration
  def self.up
    create_table :clickouts, :force => true do |t|
    t.string   :remote_ip
    t.string   :user_agent
    t.integer  :destination_id
    t.string   :destination_type
    t.string   :template
    t.integer  :position
    t.string   :platform
    t.datetime :created_at
  end

  add_index :clickouts, :remote_ip
  add_index :clickouts, :user_agent
  add_index :clickouts, :destination_id
  add_index :clickouts, :destination_type
  add_index :clickouts, :template
  add_index :clickouts, :position
  add_index :clickouts, :platform
  add_index :clickouts, :created_at
  end

  def self.down
    drop_table :clickouts
  end
end
