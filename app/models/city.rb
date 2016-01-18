class City < ActiveRecord::Base
  include Mixins::RewriteSuggestion
  acts_as_rewrite_suggestionable(
    :generate_rewrite_from => :name
  )
  
  include Mixins::HasDeltaGuard
  switch_delta_only_for(:name)

  attr_accessor :stop_update_counters

  belongs_to :state
  belongs_to :city_char
  has_many   :zip_codes,
    :dependent => :destroy
  has_many   :locations,
    :through => :zip_codes
  has_many    :geo_locations,
    :through => :zip_codes

  validates_presence_of :state, :name
  validates_associated :state
  validates_uniqueness_of :name, :scope => :state_id
  
  named_scope :showable, :conditions => 'number_of_coupons > 0'

  def before_save
    @changes = self.changes
    if @changes.include?('rewrite')
      state_rewrite = self.state.rewrite
      if self.rewrite?
        city_rewrite = self.rewrite
      else
        city_rewrite = self.generate_rewrite
      end
      self.rewrite = self.class.get_unique_rewrite("#{state_rewrite}/#{I18n.t('shared.routes.rewrite_prefix_city')}-#{city_rewrite}", self.id)
    end
    self.number_of_locations = 0 if self.number_of_locations < 0
  end
  
  before_save :check_for_city_char

  define_index do
    indexes name, :sortable => true, :prefixes  => true
    indexes zip_codes(:code), :as => :zip_code, :prefixes  => true
    indexes state.name, :as => :state_name

    has number_of_locations

    set_property :min_prefix_len => 1
    #set_property :min_infix_len => 3
    set_property :enable_star   => false
    set_property :delta => true
  end

  def incement_number_of_locations(number)
    self.number_of_locations += number
    self.save
    unless stop_update_counters === true
      self.state.incement_number_of_locations(number)
      self.city_char.incement_number_of_locations(number)
    end
  end

  def decement_number_of_locations(number)
    self.number_of_locations -= number
    self.save
    unless stop_update_counters === true
      self.state.decement_number_of_locations(number)
      self.city_char.decement_number_of_locations(number)
    end
  end

  def generate_rewrite(remove_double_words = true)
#    if self.class.include?(Mixins::RewriteSuggestion)
      new_rewrite = self.class.generate_rewrite(self.name)
      if remove_double_words == true
        rewrite_array = []
        city_rewrite_array = new_rewrite.split('-')
        city_rewrite_array.each do |el|
          el_stripped = el.strip
          unless self.state.rewrite.include?(el_stripped)
            rewrite_array << el_stripped
          end
        end
        self.rewrite = "#{self.state.rewrite}/#{rewrite_array.join('-')}"
      else
        self.rewrite = new_rewrite
      end
#    else
#      city_name = self.name.downcase
#      FormatString.normalize_charset!(city_name)
#      FormatString.remove_special_characters!(city_name)
#      rewrite=city_name.gsub(/[^\w]+/,"-")
#      self.rewrite = "#{self.state.rewrite}/#{rewrite.split('-')[0..4].join('-')}"
#    end
  end

  def update_counters
    counter = 0
    self.zip_codes.find_each({:batch_size => GLOBAL_CONFIG[:find_each_batch_size]}) do |zip_code|
      counter += zip_code.update_counters
    end
    self.update_attributes({:number_of_locations => counter})
    counter
  end

  def self.find_or_create(name, state_name)
    state = State.find_or_create(state_name)
    unless city = City.find(:first, :conditions => {:name => name, :state_id => state.id})
      city = City.create({:name => name, :state_id => state.id})
    end
    return city
  end
  
  private
  
  def check_for_city_char
    unless self.city_char_id?
      char = I18n.transliterate(self.name.strip.first).downcase
      if char.length <= 2
        if city_char = CityChar.find(:first, :conditions => {:start_char => char, :state_id => self.state_id})
          city_char.update_attributes({
            :number_of_locations => city_char.number_of_locations + self.number_of_locations
          })
        else
          city_char = CityChar.create({
            :start_char => char, 
            :state_id => self.state_id,
            :number_of_locations => self.number_of_locations
          })
        end
        self.city_char_id = city_char.id
      end
    end
  end
end
