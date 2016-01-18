class ChangeCoupons < ActiveRecord::Migration
  def self.up
    rename_column :coupons, :data_source_id, :customer_id
    
    conn = ActiveRecord::Base.connection
    result = conn.execute('SELECT id FROM customers;')
    if result.is_a?(Mysql::Result)
      ids = result.fetch_row
    elsif result.is_a?(Mysql2::Result)
      ids = result.first
    end
    unless ids.empty?
      execute("UPDATE coupons SET customer_id = #{ids.first};");
    end
    
    execute("DELETE FROM data_sources WHERE name = 'coupons4u.de';");
  end

  def self.down
    execute("INSERT INTO data_sources (name) VALUES ('coupons4u.de');");
    
    rename_column :coupons, :customer_id, :data_source_id
    
    conn = ActiveRecord::Base.connection
    result = conn.execute("SELECT id FROM data_sources WHERE name = 'coupons4u.de';")
    if result.is_a?(Mysql::Result)
      ids = result.fetch_row
    elsif result.is_a?(Mysql2::Result)
      ids = result.first
    end
    unless ids.empty?
      execute("UPDATE coupons SET data_source_id = #{ids.first};");
    end
  end
end
