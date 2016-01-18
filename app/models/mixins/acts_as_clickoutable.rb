# This module defines attributes for a model class, that can be used for clickouts.
#
# == Usage
#
# Include it in your model class an call acts_as_clickoutable with
# the attribute name(s) - each as a symbol.
#
# * include Mixins::ActsAsClickoutable
# * acts_as_clickoutable(:deeplink, :shop_url)
module Mixins::ActsAsClickoutable
  # Hook: The class/model, which includes this module,
  # calls this module method, if it will be included to the class/model.
  def self.included(klass)
    klass.instance_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end

  # --
  # define all class methods in this module
  # (e.g. Category.my_class_method)
  module ClassMethods
    # acts_as_clickoutable takes the attribute names (as symbols) that can be
    # used to get exit urls on clickouts
    def acts_as_clickoutable(*attributes)
      # define clickoutable_url_attributes class variable
      cattr_accessor :clickoutable_url_attributes

      # fill clickoutable_url_attributes class variable with attribute
      # name symbols, which contain urls for valid clickouts
      if attributes.empty?
        raise("Missing attribute(s) for acts_as_clickoutable")
      else
        self.clickoutable_url_attributes = attributes.map{|a| a.to_sym}
      end
    end
  end

  # define all instance methods in this module
  # (e.g. c = Category.find(12); c.my_instance_method)
  module InstanceMethods
    # get_clickout_url checks that the given attribute name is a valid exit
    # attribute for the class of this object.
    def get_clickout_url(attribute_name)
      ret = ''
      unless attribute_name.blank?
        attribute_name_symbol = attribute_name.to_s.to_sym
        if self.class.clickoutable_url_attributes.include?(attribute_name_symbol)
          ret = self.send(attribute_name_symbol)
        end
      end
      return ret
    end
    
    private

  end
end

module ActiveRecord
  class Base
    # This method will be overwritten in all models, which include
    # the mixin acts_as_clickoutable. Otherwise a call to this method will
    # raise an error to show, that there is no way to clickout from this object.
    def get_clickout_url(name)
      raise 'This object holds no clickoutable methods.'
    end
  end
end