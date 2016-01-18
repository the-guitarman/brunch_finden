class CreateBackendUsers < ActiveRecord::Migration
  def self.up
    create_table  :backend_users do |t|

      t.string    :login,               :null => false
      t.string    :email,               :null => false
      t.string    :crypted_password,    :null => false
      t.string    :password_salt,       :null => false

      t.integer   :login_count,         :null => false, :default => 0
      t.integer   :failed_login_count,  :null => false, :default => 0

      t.datetime  :current_login_at
      t.string    :current_login_ip
      t.datetime  :last_request_at
      t.datetime  :last_login_at

      t.string    :last_login_ip
      t.string    :persistence_token,   :null => false
      t.string    :single_access_token, :null => false
      t.string    :perishable_token,    :null => false

      t.string    :salutation
      t.string    :first_name
      t.string    :name
      t.date      :birthday

      t.text     :internal_information

      t.integer   :active,              :null => false, :default => 0
      #t.string    :state,               :null => false, :default => 'pending'
      #t.integer   :confirmation_emails, :null => false, :default => 0

      #t.boolean   :delta, :null => false, :default => true

      t.timestamp :created_at
      t.timestamp :updated_at
    end

    add_index :backend_users, :login
    add_index :backend_users, :email
    #add_index :backend_users, :delta
  end

  def self.down
    drop_table :backend_users
  end
end
