  class AddToBackendUsers < ActiveRecord::Migration
  def self.up
    add_column :backend_users, :user_roles, :string
    add_column :backend_users, :user_group, :integer
    add_column :backend_users, :salary_type, :integer
    
    
    add_column :backend_users, :gender, :string, :limit => 6
    add_column :backend_users, :country, :string
    
    add_column :backend_users, :phone_mobile, :string
    add_column :backend_users, :icq, :string
    add_column :backend_users, :skype, :string
    
    add_column :backend_users, :address, :text
    
    execute('UPDATE backend_users SET user_roles = "management"')
    execute('UPDATE backend_users SET user_roles = "administrator,management" WHERE login = "Sebastian"')
  end

  def self.down
    remove_column :backend_users, :address
    
    remove_column :backend_users, :skype
    remove_column :backend_users, :icq
    remove_column :backend_users, :phone_mobile
    remove_column :backend_users, :country
    remove_column :backend_users, :gender
    
    
    remove_column :backend_users, :salary_type
    remove_column :backend_users, :user_group
    remove_column :backend_users, :user_roles
  end
end
