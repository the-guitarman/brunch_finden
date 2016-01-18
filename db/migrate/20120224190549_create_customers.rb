class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string   :name
      t.string   :customer_type
      t.text     :url
      t.text     :internal_information, :null => false
      t.integer  :state, :limit => 1, :null => false
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :customers, :name
    add_index :customers, :state
    
    execute("INSERT INTO customers (id, name, customer_type, url, state, created_at, updated_at) " + 
      "VALUES (1, 'coupons4you.de', 'Coupon Supplier', 'http://www.coupons4you.de', 1, '#{Time.now.to_s(:db)}', '#{Time.now.to_s(:db)}');")
  end

  def self.down
    drop_table :customers
  end
end
