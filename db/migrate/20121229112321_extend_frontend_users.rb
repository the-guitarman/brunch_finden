class ExtendFrontendUsers < ActiveRecord::Migration
  def self.up
    change_table :frontend_users do |t|
      t.integer  :active, :after => :id, :default => 0, :null => false
      t.integer  :score, :after => :active, :default => 0, :null => false
      t.integer  :confirmation_reminders_to_send, :after => :score
      t.boolean  :general_terms_and_conditions, :after => :confirmation_reminders_to_send
      t.integer  :login_count, :after => :general_terms_and_conditions, :default => 0, :null => false
      t.integer  :failed_login_count, :after => :login_count, :default => 0, :null => false
      
      t.string   :login, :after => :failed_login_count
      #t.string   :email, :null => false
      t.string   :new_email, :after => :email, :default => '', :null => false
      
      #t.string   :single_access_token
      #t.string   :persistence_token
      t.string   :perishable_token, :after => :persistence_token, :null => false
      
      #t.datetime :created_at
      #t.datetime :updated_at
      t.datetime :confirmed_at, :after => :updated_at
      
      t.string   :state, :default => 'pending', :null => false
      
      t.string   :crypted_password
      t.string   :password_salt
      t.datetime :current_login_at
      t.string   :current_login_ip
      t.datetime :last_request_at
      t.datetime :last_login_at
      t.string   :last_login_ip
      
      t.string   :salutation
      t.string   :first_name
      t.string   :name_2
      t.date     :birthday
      t.string   :phone
      t.string   :gender, :default => 'undefined', :null => false
      t.string   :about_user_short
      t.text     :about_user_long
      t.text     :internal_information
    end
    
    execute("UPDATE frontend_users SET name_2 = name, state = 'unknown';")
    
    remove_column :frontend_users, :name
    rename_column :frontend_users, :name_2, :name

    add_index :frontend_users, :email
    add_index :frontend_users, :login
  end
  
  def self.down
    remove_index :frontend_users, :email
    remove_index :frontend_users, :login
    
    change_table :frontend_users do |t|
      t.remove  :active
      t.remove  :score
      t.remove  :confirmation_reminders_to_send
      t.remove  :general_terms_and_conditions
      t.remove  :login_count
      t.remove  :failed_login_count
      
      t.remove  :login
      t.remove  :new_email
      
      t.remove  :perishable_token
      
      t.remove  :confirmed_at
      
      t.remove  :state
      
      t.remove  :crypted_password
      t.remove  :password_salt
      t.remove  :current_login_at
      t.remove  :current_login_ip
      t.remove  :last_request_at
      t.remove  :last_login_at
      t.remove  :last_login_ip
      
      t.remove  :salutation
      t.remove  :first_name
      t.remove  :birthday
      t.remove  :phone
      t.remove  :gender
      t.remove  :about_user_short
      t.remove  :about_user_long
      t.remove  :internal_information
    end
  end
end