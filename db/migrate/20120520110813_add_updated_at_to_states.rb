class AddUpdatedAtToStates < ActiveRecord::Migration
  def self.up
    add_column :states, :updated_at, :datetime
    execute('UPDATE states SET updated_at = NOW();')
    
    add_column :cities, :updated_at, :datetime
    execute('UPDATE cities SET updated_at = NOW();')
  end

  def self.down
    remove_column :cities, :updated_at
    remove_column :states, :updated_at
  end
end
