# If this is included in a model, the model has associations with reviews.
# Used for {Product} and {Shop}.
module Mixins::ActsAsRateable
  # Hook: The class/model, which includes this module,
  # calls this module method, if it will be included to the class/model.
  def self.included(klass)
    klass.instance_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end

  # define all class methods in this module
  # (e.g. Category.my_class_method)
  module ClassMethods
    def acts_as_rateable(options = {})
      # ASSOCIATIONS -----------------------------------------------------------
      has_many :aggregated_ratings, :dependent => :destroy, :as=>:destination
      has_many :ratings, :dependent => :destroy,:through=>:reviews

      has_one :aggregated_review, :dependent => :destroy, :as => :destination
      has_many :reviews, :dependent => :destroy, :as => :destination
    end

    def rateable?
      true
    end
  end

  # define all instance methods in this module
  # (e.g. c = Category.find(12); c.my_instance_method)
  module InstanceMethods
    # Returns the review template, that belongs to the destination.
    def review_template
      if Rails.version >= '3.0.0'
        destination_type = ReviewTemplate::DESTINATION_TYPES.key(
          self.class.base_class.name.underscore)
      else
        destination_type = ReviewTemplate::DESTINATION_TYPES.index(
          self.class.base_class.name.underscore)
      end
      return ReviewTemplate.find_by_destination_type(destination_type)
    end
    
    
  end
end

module ActiveRecord
  class Base
    def rateable?
      self.class.rateable?
    end

    def self.rateable?
      false
    end
  end
end
