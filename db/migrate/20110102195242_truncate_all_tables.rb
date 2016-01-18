class TruncateAllTables < ActiveRecord::Migration
  def self.up
    execute("TRUNCATE TABLE #{GeoLocation.table_name}")
    execute("TRUNCATE TABLE #{Location.table_name}")
    execute("TRUNCATE TABLE #{ZipCode.table_name}")
    execute("TRUNCATE TABLE #{City.table_name}")
    execute("TRUNCATE TABLE #{State.table_name}")
  end

  def self.down
  end
end
