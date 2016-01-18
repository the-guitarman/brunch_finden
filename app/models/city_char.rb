class CityChar < ActiveRecord::Base
  attr_accessor :stop_update_counters
  
  belongs_to :state
  has_many :cities, :order => 'name ASC'
  
  validates_presence_of :start_char, :state

  def incement_number_of_locations(number)
    self.number_of_locations += number
    self.save
  end

  def decement_number_of_locations(number)
    self.number_of_locations -= number
    self.save
  end

  def update_counters
    counter = 0
    self.cities.find_each({:batch_size => GLOBAL_CONFIG[:find_each_batch_size]}) do |city|
      counter += city.update_counters
    end
    self.update_attributes({:number_of_locations => counter})
    counter
  end
end