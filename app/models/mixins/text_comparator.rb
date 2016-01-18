#encoding: utf-8

module Mixins::TextComparator
  TEXT_CHANGE_TRIGGER_VALUE = 90
  
  def self.included(klass)
    klass.instance_eval do
      extend ClassMethods
      #include InstanceMethods
    end
  end

  #module InstanceMethods
  #end

  module ClassMethods
    # Adds clean_<field_name> method to model
    # field must be a String or a Symbol
    def check_text_changes_in(field)
      eval "before_update :text_changes_okay_in_#{field}"
      
      class_eval "
        def text_changes_okay_in_#{field}
          if is_complete_review? and not self.#{field}_was.blank?
            if (percent_changes=Mixins::TextComparator.compare_text(self.#{field}_was,self.#{field})>
                Mixins::TextComparator::TEXT_CHANGE_TRIGGER_VALUE)
              true
            else
              errors.add(:text,'Scheinbar hast du zu viele Änderungen vorgenommen. Bitte versuche die Grundaussage des Testberichts nicht zu ändern. Wenn du etwas anfügen willst, so kannst du das aber jederzeit tun.')
              false
          
            end
          else
            true
          end
        end"
    end
  end
  
  # Eliminates special chars from given text.
  # Heeds also german umlauts.
  # @params [String] text
  # @return String clean text
  def self.compare_text(text_from,text_to)
    text_a=text_from.simplify.split
    text_b=text_to.simplify.split
    position=-1 #set cursor in front of stream start point
    hits=0 #counter of found words
    text_a.each do |word_a| 
      if new_pos=text_b[position+1..-1].index(word_a) 
        position=new_pos
        hits+=1
      end
    end
    return (hits*100/text_a.count)
  end
end


class String
  def simplify
    self.downcase.gsub(/[^a-zA-Z0-9]+/," ")
  end
end