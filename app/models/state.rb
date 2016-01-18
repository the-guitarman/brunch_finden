class State < ActiveRecord::Base
  include Mixins::RewriteSuggestion
  acts_as_rewrite_suggestionable(
    :generate_rewrite_from => :name
  )
  
  has_many :cities, :dependent => :destroy
  has_many :city_chars, :dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  def before_save
    self.number_of_locations = 0 if self.number_of_locations < 0
  end
  
#  def cache_key
#    [
#      self.class.name,
#      self.id.to_i.to_s,
#      self.updated_at.to_i.to_s,
#      self.cities.showable.count.to_s
#    ].join(':')
#  end
  
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

  def self.find_or_create(name)
    unless state = State.find_by_name(name)
      state = State.create({:name => name})
    end
    return state
  end
end
