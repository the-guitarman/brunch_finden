# This mixin holds a class method to generate a valid rewrite suggestion.
# 
# Important: The class/model, which includes this mixin,
# needs the :rewrite attribute.
#
# Note: There is no need to call any class or instance method on before create
# an object. In this case the generate_rewrite method of its class will be called,
# if the object has no rewrite. Otherwise you can use the method to do some
# rewrite suggestions: obj.class.generate_rewrite(obj.name)
module Mixins::RewriteSuggestion
  # Hook: The class/model, which includes this module,
  # calls this module method, if it will be included to the class/model.
  def self.included(klass)
    klass.instance_eval do
      extend ClassMethods
      include InstanceMethods

#      validates_presence_of :rewrite

      #before_validation :before_validation_rewrite_suggestion_handler
      #before_create :before_create_rewrite_suggestion_handler
      #before_update :before_update_rewrite_suggestion_handler
#      before_save :before_save_rewrite_suggestion_handler
    end
  end

  # define all class methods in this module
  # (e.g. Category.my_class_method)
  module ClassMethods
    # Extends each object with instance variable @generate_rewrite_by
    # This variable identifies the attribute from with to generate the rewrite. 
    # Example:
    # class Shop
    #   acts_as_rewrite_suggestionable(
    #     :generate_rewrite_by => :name
    #   )
    # end
    def acts_as_rewrite_suggestionable(options_hash)
      rewrite_from_attr = options_hash.delete(:generate_rewrite_from)
      unless rewrite_from_attr.blank?
        class_eval "
          validates_presence_of :#{rewrite_from_attr}
          validates_presence_of :rewrite #,
            #:if => :#{rewrite_from_attr}?
          validates_uniqueness_of :rewrite #,
            #:if => :#{rewrite_from_attr}?

          before_validation :before_save_rewrite_suggestion_handler

          def self.generate_rewrite_from
            '#{rewrite_from_attr}'
          end"
      else
        raise("Missing :generate_rewrite_from for acts_as_rewrite_suggestionable")
      end
    end

    def generate_rewrite(str, id = false, unique = true)
      temp = str.downcase
      # replace umlaute
      FormatString.normalize_charset!(temp)    
      # replace special characters
      FormatString.remove_special_characters!(temp)
      # replace invalid chars with "-" but disable multi "-"
      rewrite=temp.gsub(/[^\w]+/,"-")
      # limit to 5 words
      rewrite = rewrite.split('-')[0..4].join('-')
      # check uniqeness of rewrite
      if unique == true
        get_unique_rewrite(rewrite,id)
      else
        rewrite
      end
    end

    def get_unique_rewrite(rewrite,id=false)
      if id
        conditions = "((rewrite LIKE '#{rewrite}--%') OR (rewrite LIKE '#{rewrite}')) AND (id != #{id})"
      else
        conditions = "(rewrite LIKE '#{rewrite}--%') OR (rewrite LIKE '#{rewrite}')"
      end
      found_objects = self.find(:all, :conditions => conditions)
      if found_objects.empty?
        # there is no other object of this class with the same rewrite, 
        # so return the rewrite suggestion
        return rewrite
      end
      # oh no, rewrite exists, so ...
      max_rewrite_num = 0
      curr_rewrite_num = 0
      found_objects.each do |obj|
        tmp = obj.rewrite.split('--')
        if tmp[1]
          curr_rewrite_num = tmp[1].to_i
          max_rewrite_num = curr_rewrite_num if curr_rewrite_num > max_rewrite_num
        end
      end
      # add '--' and number to rewrite if it isn't unique
      rewrite_num = max_rewrite_num + 1
      rewrite_num = 2 if rewrite_num < 2
      return "#{rewrite}--#{rewrite_num}"
    end
  end

  # define all instance methods in this module
  # (e.g. c = Category.find(12); c.my_instance_method)
  module InstanceMethods
    
    private

    # Called before validations will be executed.
    def before_validation_rewrite_suggestion_handler
      generate_valid_rewrite
    end

    # Called on before_save of the object.
    def before_save_rewrite_suggestion_handler
      generate_valid_rewrite
    end

    # Called on before_create of the object.
    def before_create_rewrite_suggestion_handler
      generate_valid_rewrite
    end
    
    # Called on before_update of the object.
    def before_update_rewrite_suggestion_handler
      generate_valid_rewrite
    end

    # Check, wether there is a rewrite. If not, generate a valid one
    def generate_valid_rewrite
      unless self.rewrite?
        attribute_name = self.class.generate_rewrite_from.to_sym
        if attribute_value = self.send(attribute_name)
          self.rewrite = self.class.generate_rewrite(attribute_value)
        end
      end
    end
  end
end
