class CreateAccountCheaters < ActiveRecord::Migration
  def self.up
    create_table :account_cheaters do |t|
      t.integer  :frontend_user_id
      t.string   :other_users,      :default => ""
      t.string   :client_ip,        :default => ""
      t.string   :client_agent,     :default => ""
      t.integer  :switches,         :default => 0
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :cheating_values,  :default => ""
      t.boolean  :ignored,          :default => false
      t.boolean  :killed,           :default => false
    end
    
    add_index :account_cheaters, :frontend_user_id
  end

  def self.down
    drop_table :account_cheaters
  end
end
