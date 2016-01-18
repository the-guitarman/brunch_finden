class CreateStates < ActiveRecord::Migration
  def self.up
    # GRANT ALL PRIVILEGES ON *.* TO 'monty'@'localhost' IDENTIFIED BY 'some_pass' WITH GRANT OPTION;
    create_table :states do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :states
  end
end
