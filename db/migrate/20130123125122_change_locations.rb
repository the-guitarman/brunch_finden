class ChangeLocations < ActiveRecord::Migration
  def self.up
    remove_index :locations, :email
    
    #add_column :locations, :frontend_user_id_new, :integer, :after => :zip_code_id
    #execute('UPDATE locations SET frontend_user_id_new = frontend_user_id')
    #remove_column :locations, :frontend_user_id
    #rename_column  :locations, :frontend_user_id_new, :frontend_user_id
    move_column :locations, :frontend_user_id, :integer, :after => :zip_code_id    
    move_column :locations, :general_terms_and_conditions_confirmed, :boolean, :after => :frontend_user_id
    move_column :locations, :published, :boolean, :after => :general_terms_and_conditions_confirmed
    move_column :locations, :delta, :integer, :after => :published, :default => 1, :null => false
    move_column :locations, :rewrite, :string, :after => :delta
    move_column :locations, :confirmation_code, :string, :after => :rewrite
    
    add_index :locations, :zip_code_id
    add_index :locations, :frontend_user_id
    add_index :locations, :rewrite
    add_index :locations, :confirmation_code
  end

  def self.down
    remove_index :locations, :zip_code_id
    remove_index :locations, :frontend_user_id
    #remove_index :locations, :rewrite
    remove_index :locations, :confirmation_code
    
    add_index :locations, :email
  end
end
