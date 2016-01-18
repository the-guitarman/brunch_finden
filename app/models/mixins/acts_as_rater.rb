module Mixins::ActsAsRater
  def self.included(klass)
    klass.instance_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end
  
  module ClassMethods
    def acts_as_rater(options = {})
      has_many :reviews, :dependent => :destroy
    end
    
    def rater?
      true
    end
  end
  
  module InstanceMethods
    def destroyable?
      if self.reviews.count > 0
        false
      else
        true
      end
    end
  end
end

module ActiveRecord
  class Base
    def rater?
      self.class.rater?
    end

    def self.rater?
      false
    end
  end
end
