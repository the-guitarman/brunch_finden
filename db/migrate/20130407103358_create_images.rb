class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :location_images do |t|
      t.integer  :location_id
      t.integer  :frontend_user_id, :default => 0
      t.integer  :review_id,        :default => 0
      t.integer  :data_source_id
      t.integer  :image_width
      t.integer  :image_height
      t.integer  :image_size
      t.integer  :set_watermark,    :default => 0, :null => false
      
      t.boolean  :is_hidden,        :default => false, :null => false
      t.boolean  :is_deleted,       :default => false, :null => false
      t.boolean  :is_main_image,    :default => false, :null => false
      t.boolean  :uploader_denied_main_image, :default => false, :null => false
      
      t.datetime :created_at
      t.datetime :updated_at
      
      t.string   :title
      t.string   :description
      t.string   :image_format,     :default => :png, :limit => 10
      t.string   :presentation_type
      t.string   :status,           :default => :new, :limit => 10
      t.string   :tags,             :default => ''
    end

    add_index :location_images, :location_id
    add_index :location_images, :frontend_user_id
    add_index :location_images, :review_id
  end

  def self.down
    drop_table :location_images
  end
end
