class AggregatedReview < ActiveRecord::Base
  include Mixins::PolymorphicFinder

  include Mixins::CentInteger
  cover_as_cent_integer :value
  
  VALUE_BETWEEN = [0.0,1.0]
  
  belongs_to :destination, :polymorphic => true
  polymorphic_finder_for :destination
  
  before_validation :before_validation_on_create_handler, {:on => :create}
  
  validates_presence_of :destination
  validates_uniqueness_of :destination_id,
    :scope => :destination_type
  validates_numericality_of :user_count,
    :greater_than => 0,
    :only_integer => true
  validates_numericality_of :value,
    :greater_than_or_equal_to => 0,
    :less_than_or_equal_to => 1

  def recalculate
    AggregatedReview.recalculate(self.destination)
  end

  # Returns a hash with 'review value => number users' structure like:
  # {0.2 => 2, 0.6 => 3, 0.8 => 5, 1.0 => 10}
  def users_per_value
    unless self[:users_per_value].blank?
      YAML::load(self[:users_per_value])
    else
      AggregatedReview.users_per_value
    end
  end

  # Consumes a hash with a single 'review value => number users' and adds the
  # number of users to the number of users of the given review value:
  # ac = AggregatedReview.first
  # ac.users_per_value               # => {0.2 => 2, 0.6 => 3}
  # ac.users_per_value = {0.2 => -1} # => {0.2 => 1, 0.6 => 3}
  # ac.users_per_value = {0.4 => 1}  # => {0.2 => 1, 0.4 => 1, 0.6 => 3}
  def users_per_value=(value = {})
    unless value.blank?
      value.stringify_keys!
      key = value.keys.first
      unless self[:users_per_value].blank?
        values = YAML::load(self[:users_per_value])
#        values.stringify_keys!
        if values.has_key?(key.to_f)
          values[key.to_f] += value[key].to_i
        else
          values[key.to_f] = value[key].to_i
        end
        values.each{|k,v| values[k] = 0 if v < 0}
        self[:users_per_value] = values.ya2yaml #.to_yaml
      else
        value[key.to_f] = 0 if value[key] < 0
        self[:users_per_value] = value.ya2yaml #.to_yaml
      end
    else
      self[:users_per_value] = AggregatedReview.users_per_value.ya2yaml #.to_yaml
    end
  end

  def self.find_or_create(destination)
    AggregatedReview.find_or_create_by_destination_type_and_destination_id(
      destination.class.base_class.name,destination.id)
  end

  def self.recalculate(destination)
    if aggregated_review = find_or_create(destination)
      reviews = Review.destination(destination).showable.all
      value = 0
      aggregated_review.users_per_value = nil
      reviews.each do |review|
        value += review.value
        user_to_value = {}
        user_to_value[review.value.to_f] = 1
        aggregated_review.users_per_value = user_to_value
      end
      value = reviews.length > 0 ? value / reviews.length : value

      aggregated_review.user_count = reviews.length
      aggregated_review.value = value
      aggregated_review.save if aggregated_review.changed?
    end
  end

  def self.recalculate_all
    AggregatedReview.find_each do |ac|
      AggregatedReview.recalculate(ac.destination)
    end
    return nil
  end

  def self.users_per_value
    proc = Proc.new{|k,v| k_10 = k * 10; (k_10 - k_10.to_i) == 0 and v.is_a?(Integer)}
    values = {}
    Review::VALUES.find_all{|k,v| proc.call(k,v)}.map{|el| el.first}.each  do |key|
      values[key.to_f] = 0
    end
    return values
  end
  
  private

  def before_validation_on_create_handler
    self.user_count = 0 unless self.user_count?
    self.value = 0 unless self.value?
  end
end