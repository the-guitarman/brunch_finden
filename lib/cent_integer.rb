# This module offers a cheap posibility to save 
# fixed decimal place floats as integer values in database.
module Mixins::CentInteger
  def self.included(klass)
    klass.instance_eval do
      extend AccessMethods
    end
  end

  module AccessMethods
    # attribute_string will be saved as integer in DB, but
    # will be a float with 2 decimal places in application
    def cover_as_cent_integer(attribute_string)
      cover_integer_as_float(attribute_string,2)
    end
    
    # attribute_string will be saved as integer in DB, but
    # will be a float with 3 decimal places in application
    def cover_as_milli_integer(attribute_string)
      cover_integer_as_float(attribute_string,3)
    end
    
    def cover_integer_as_float(attribute_string,decimal_place=2)
      class_eval "
        # Overwrites <attr_name>_before_type_cast method, because it's used to 
        # validate the numericality of the attribute, but it would return an 
        # integer as read from the database instead of a float value, which is 
        # expected in the validates_numericality_of statement. 
        # please see: http://railspikes.com/2009/3/5/today-s-hard-won-lesson
        def #{attribute_string}_before_type_cast
          return nil if super.blank?
          return super.to_f/1#{'0'*decimal_place}
        end

        def #{attribute_string}
          return nil if read_attribute(:#{attribute_string}).blank?
          return read_attribute(:#{attribute_string}).to_f/1#{'0'*decimal_place}
        end
        
        def #{attribute_string}=(val)
          if val.blank?
            write_attribute(:#{attribute_string}, nil)
          else
            write_attribute(:#{attribute_string}, val.to_f*1#{'0'*decimal_place})
          end
        end"
      
      instance_eval "
        if Rails.version >= '3.0.0'
          scope :#{attribute_string}, lambda{|val| where({:#{attribute_string} => val.to_f*1#{'0'*decimal_place}})}
        else
          named_scope :#{attribute_string}, lambda{|val| {:conditions => {:#{attribute_string} => val.to_f*1#{'0'*decimal_place}}}}
        end
      "
    end
  end
end
