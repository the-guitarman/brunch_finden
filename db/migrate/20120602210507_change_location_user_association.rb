class ChangeLocationUserAssociation < ActiveRecord::Migration
  class Location < ActiveRecord::Base
    has_one :user, :dependent => :destroy
  end
  class User < ActiveRecord::Base
    belongs_to :location
    private
    def after_create_handler; end
  end
  def self.up
    add_column :locations, :frontend_user_id, :integer
    add_column :locations, :general_terms_and_conditions_confirmed, :boolean
    
    create_table :frontend_users do |t|
      t.string   :name,                :null => false
      t.string   :email,               :null => false
      t.string   :single_access_token#, :null => false
      t.string   :persistence_token#,   :null => false
      t.datetime :created_at
      t.datetime :updated_at
    end    
    domain_name = CustomConfigHandler.instance.frontend_config['DOMAIN']['NAME'].downcase
    execute("INSERT INTO frontend_users (name, email) VALUES ('#{domain_name}', 'info@#{domain_name}');")
    
    ThinkingSphinx.deltas_enabled=false
    Location.find_each({:batch_size => ::GLOBAL_CONFIG[:find_each_batch_size]}) do |l|
      user = l.user
      if fu = FrontendUser.find_by_email(user.email)
        l.frontend_user = fu
      else
        l.frontend_user = FrontendUser.create({:name  => user.name, :email => user.email})
      end
      l.general_terms_and_conditions_confirmed = user.general_terms_and_conditions_confirmed
      l.save
    end
    
    drop_table :users
  end

  def self.down
    create_table :users do |t|
      t.integer  :location_id
      t.string   :name,                :null => false
      t.string   :email,               :null => false
      t.boolean  :general_terms_and_conditions_confirmed
      t.string   :single_access_token, :null => false
      t.string   :persistence_token,   :null => false
      t.datetime :created_at
      t.datetime :updated_at
    end
    
    Location.find_each({:batch_size => ::GLOBAL_CONFIG[:find_each_batch_size]}) do |l|
      frontend_user = l.frontend_user
      User.create({
        :location_id => l.id,
        :name  => frontend_user.name,
        :email => frontend_user.email,
        :general_terms_and_conditions_confirmed => l.general_terms_and_conditions_confirmed
      })
    end
    
    drop_table :frontend_users
    
    remove_column :locations, :general_terms_and_conditions_confirmed
    remove_column :locations, :frontend_user_id
  end
end
