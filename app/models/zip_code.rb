class ZipCode < ActiveRecord::Base
  include Mixins::HasDeltaGuard
  switch_delta_only_for(:code)
  
  attr_accessor :do_not_geocode

  belongs_to :city
  has_many   :locations,
    :dependent => :destroy
  has_one    :geo_location,
    :as        => :geo_code,
    :dependent => :destroy

  validates_presence_of :city, :code
  validates_associated :city
  validates_uniqueness_of :code, :scope => :city_id
  validates_length_of :code, :is => 5

  def before_save
    self.number_of_locations = 0 if self.number_of_locations < 0
    @changes = self.changes
  end

  def after_save
    if @changes.include?('code') or
       @changes.include?('city_id') or @changes.include?('city')
      geocode unless do_not_geocode === true
    end
  end

  define_index do
    indexes code, :sortable => true

    #set_property :min_infix_len => 2
    set_property :enable_star   => false
    set_property :delta => true
  end

  def incement_number_of_locations(number)
    self.number_of_locations += number
    self.save
    self.city.incement_number_of_locations(number)
  end
  
  def decement_number_of_locations(number)
    self.number_of_locations -= number
    self.save
    self.city.decement_number_of_locations(number)
  end

  def update_counters
    counter = self.locations.count
    self.update_attributes({:number_of_locations => counter})
    counter
  end

  def self.find_or_create(code, city_name, state_name)
    city = City.find_or_create(city_name, state_name)
    unless zip_code = ZipCode.find(:first, :conditions => {:code => code, :city_id => city.id})
      zip_code = ZipCode.create({:code => code, :city_id => city.id, :do_not_geocode => true})
    end
    return zip_code
  end

#  private
  
  def geocode_string
    "#{self.code}, #{self.city.name}, #{self.city.state.name}"
  end
  
  def geocode    
    self.geo_location = GeoLocation.new unless self.geo_location
    if self.geo_location.geocode(geocode_string)
      self.geo_location.save
    else
      self.geo_location.destroy unless self.geo_location.new_record?
    end
  end
end
