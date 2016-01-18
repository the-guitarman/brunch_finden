class LocationSuggestion < ActiveRecord::Base
  validates_presence_of :name, :city
  validate :validate_city_name
  
  after_create :after_create_handler
  
  private
  
  def after_create_handler
    send_creation_email
  end
  
  def send_creation_email
    Mailers::Frontend::LocationSuggestionMailer.deliver_location_suggestion(self)
  end
  
  def validate_city_name
    unless self.city.blank?
      unless City.find(:first, :conditions => {:name => self.city})
        self.errors.add(:city, :invalid)
      end
    end
  end
end