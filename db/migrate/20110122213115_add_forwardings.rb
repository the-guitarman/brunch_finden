class AddForwardings < ActiveRecord::Migration
  def self.up
    create_table :forwardings do |t|
      t.string :source_url,       :limit => 2048, :null => false
      t.string :destination_url,  :limit => 2048, :null => false
      t.timestamp :last_use_at
      t.timestamps
    end

    add_index(:forwardings, :source_url)
    add_index(:forwardings, :destination_url)
  end

  def self.down
    drop_table :forwardings
  end
end
