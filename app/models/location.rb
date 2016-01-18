#require 'csv'

class Location < ActiveRecord::Base
  attr_accessor :do_not_geocode
  
  DELETION_LOG_FILE = "#{Rails.root}/log/review_deletions.log"

  belongs_to :frontend_user
  belongs_to :zip_code
  has_one    :geo_location,
    :as        => :geo_code,
    :dependent => :destroy
  
  has_many :images, :class_name => 'LocationImage', :dependent => :destroy
  has_many :reviews, :dependent => :destroy
  has_one :aggregated_review, :dependent => :destroy
  has_many :aggregated_ratings, :dependent => :destroy
  
  include Mixins::SecureCode
  secure_code_for :confirmation_code
  
  include Mixins::ActsAsRateable
  acts_as_rateable

  include Mixins::RewriteSuggestion
  acts_as_rewrite_suggestionable(
    :generate_rewrite_from => :name
  )
  
  include Mixins::HasDeltaGuard
  switch_delta_only_for(:name, :street, :published)

  validates_amount_format_of :price,
    :unless => Proc.new{|l| l.amount_field_price.blank?}
  validates_numericality_of :price,
    #:if => :price?,
    :greater_than => 0,
    :allow_nil => true
  validates_presence_of :name, :zip_code, :street, :phone #, :price
  validates_format_of :phone,
    :with => /^((\+[0-9]{2,4}( [0-9]+? | ?\([0-9]+?\) ?))|(\(0[0-9 ]+?\) ?)|(0[0-9]+? ?( |-|\/) ?))[0-9]+?[0-9 \/-]*[0-9]$/,
    :if   => :phone?
  # on create, a new frontend user has no id, but the 
  # frontend user associated should be present and ...  
  validates_presence_of :frontend_user, :on => :create
  # ... valid, if it's a new frontend user
  validates_associated :frontend_user, :on => :create,
    :if => Proc.new{|r| r.frontend_user and r.frontend_user.new_record?}
  # on update, there have to be a frontend_user_id, 
  # because the frontend_user should exist
  validates_presence_of :frontend_user_id, :on => :update
  validates_associated :zip_code
  validates_uniqueness_of :name, :scope => :zip_code_id
  validates_acceptance_of :general_terms_and_conditions_confirmed,
    :allow_nil => false,
    :accept    => true

#  validates_presence_of :email
  validates_length_of :email, validates_length_of_email_field_options.merge({:if => :email?})
  validates_format_of :email, validates_format_of_email_field_options.merge({:if => :email?})
  #validates_uniqueness_of :email, validates_uniqueness_of_email_field_options

  named_scope :showable, :conditions => {:published => true}
  named_scope :unpublished, :conditions => {:published => false}

  def before_validation
    if self.street == Location.human_attribute_name(:street)
      self.street = nil
    end
  end

  def before_save
    @changes = self.changes
    if @changes.include?('rewrite')
      city_rewrite = self.zip_code.city.rewrite
      if self.rewrite?
        location_rewrite = self.rewrite
      else
        location_rewrite = self.class.generate_rewrite(self.name)
      end
      self.rewrite = self.class.get_unique_rewrite("#{city_rewrite}/#{location_rewrite}", self.id)
    end
  end
  
  def before_update
    if @changes.include?('name') and (not @changes.include?('rewrite'))
      city_rewrite = self.zip_code.city.rewrite
      location_rewrite = self.class.generate_rewrite(self.name)
      self.rewrite = "#{city_rewrite}/#{location_rewrite}"
      @changes = self.changes
    end
  end

  def after_save
    if @changes.include?('name') or @changes.include?('street') or 
       @changes.include?('zip_code_id') or @changes.include?('zip_code')
      geocode unless do_not_geocode === true
    end
    if @changes.include?('published')
      if @changes['published'][0] != true and @changes['published'][1] == true
        increment_locations_counter
        touch_associated
      elsif @changes['published'][0] == true and @changes['published'][1] == false
        decrement_locations_counter
      end
    end
  end

  after_destroy :log_deletion, :decrement_locations_counter_if_published, :touch_associated

  def after_initialize
    self.do_not_geocode = false
  end

  define_index do
    indexes name, :sortable => true, :prefixes  => true
    indexes street, :sortable => true, :prefixes  => true
    indexes zip_code.code, :as => :zip_code, :prefixes  => true
    indexes zip_code.city.name, :as => :city_name, :prefixes  => true
    indexes zip_code.city.state.name, :as => :state_name

    #has location(:id)
    has :id
    has published
    has published, :as => :showable, :type => :boolean
    
    has "RADIANS(geo_locations.lat)", :as => :latitude,  :type => :float
    has "RADIANS(geo_locations.lng)", :as => :longitude, :type => :float
#    has geo_location.lat, :as => :latitude,  :type => :float
#    has geo_location.lng, :as => :longitude, :type => :float
    has geo_location.lat, :as => :geo_location_lat,  :type => :float
    has geo_location.lng, :as => :geo_location_lng, :type => :float
    set_property :latitude_attr  => 'latitude'
    set_property :longitude_attr => 'longitude'

    set_property :min_prefix_len => 1
    #set_property :min_infix_len => 3
    set_property :enable_star   => false
    set_property :delta => true
  end

  #private
  
  def geocode_string
    ret = "#{self.name},#{self.street},#{self.zip_code.code},#{self.zip_code.city.name}"
    state = self.zip_code.city.state.name
    ret += ",#{state}" unless ret.include?(state)
    return ret
  end

  def geocode    
    self.geo_location = GeoLocation.new unless self.geo_location
    if self.geo_location.geocode(geocode_string)
      self.geo_location.save
    else
      self.geo_location.destroy unless self.geo_location.new_record?
    end
  end
  
  def review_template
    type = ReviewTemplate::DESTINATION_TYPES.index(self.class.name.downcase)
    return ReviewTemplate.find_by_destination_type(type)
  end
  
#  def self.to_csv(conditions)
#    CSV.generate do |csv|
#      csv << column_names.sort
#      find_each({:conditions => conditions}) do |location|
#        csv << location.attributes.values_at(*column_names)
#      end
#    end
#  end

  def self.find_or_create(name, street, code)
    zip_code = ZipCode.find_by_code(code)
    return Location.create({:name => name, :street => street, :zip_code => zip_code, :do_not_geocode => true})
  end
  
  private
  
  def decrement_locations_counter_if_published
    if self.published == true
      decrement_locations_counter
    end
  end
  
  def decrement_locations_counter
    self.zip_code.decement_number_of_locations(1)
  end
  
  def increment_locations_counter
    self.zip_code.incement_number_of_locations(1)
  end
  
  def log_deletion
    msg = "#{I18n.l(Time.now, :format => :log_file)}, " +
      "LOCATION #{self.attributes}, " +
      "FRONTEND USER: #{self.frontend_user.attributes.inspect}" +
      "\n"
    File.open(DELETION_LOG_FILE, 'a') do |f|
      f.write(msg)
    end
  end

  def touch_associated
    self.zip_code.city.touch
  end
end
