class GeoLocation < ActiveRecord::Base
  belongs_to :geo_code, :polymorphic => true

  #geocoded_by :address, {:latitude  => :lat, :longitude => :lng}
  #after_validation :geocode
  #
  #reverse_geocoded_by :lat, :lng, {:address => :address}
  #after_validation :reverse_geocode  # auto-fetch address

  validates_presence_of :geo_code_id, :geo_code_type, :lat, :lng
  validates_uniqueness_of :geo_code_id, :scope => [:geo_code_type]
  validates_numericality_of :geo_code_id,
    :greater_than => 0,
    :only_integer => true
  validates_numericality_of :lat, :lng

  def validate
    check_geo_code_type
  end
  
  #def address
  #  self.geo_code.geocode_string
  #end
  #
  #def address(addr)
  #  
  #end

  def geocode(address)
    result = Geocoder.search(address).first
    #result.latitude - float
    #result.longitude - float
    #result.coordinates - array of the above two
    #result.address - string
    #result.city - string
    #result.state - string
    #result.state_code - string
    #result.postal_code - string
    #result.country - string
    #result.country_code - string
    if result
      self.lat = result.latitude
      self.lng = result.longitude
      return true
    else
      return nil
    end
  end

  def self.cleaner(options={})
    show_messages = options[:show_messages].nil? ? true : options[:show_messages]
    if show_messages
      puts; print 'Clean up geo locations ...'
      count = 0
    end
    locations = GeoLocation.find(:all)
    locations.each do |l|
      if not ActiveRecord::Base.check_for_model_class?(l.geo_code_type) or
         l.geo_code_type.constantize.abstract_class? or
         l.geo_code.blank?
        l.destroy
        print_char = 'd'
      else
        print_char = '.'
      end
      if show_messages
        count += 1
        print print_char
      end
    end
    if show_messages
      puts " done! (processed: #{count})"
    end
    nil
  end

  private

  # checks, that attribute geo_code_type contains a model class only
  def check_geo_code_type
    unless ActiveRecord::Base.check_for_model_class?(self.geo_code_type)
      self.errors.add(:geo_code_type, 'should be a model class name')
      return false
    end
    return true
  end
end