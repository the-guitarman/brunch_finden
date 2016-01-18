#encoding: utf-8

module Mixins::BadWordChecker
  def self.included(klass)
    klass.instance_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end
  
  module ClassMethods
    # Adds clean_<field_name> method to model
    # field must be a String or a Symbol
    def bad_word_check_for(*fields)
      options = fields.extract_options! || {}
      
      fields = fields.map{|f| f.to_s}.compact.uniq
      fields.delete_if{|f| f.blank?}
      raise 'There are no fields to check for bad words.' if fields.empty?
      
      cattr_accessor :attributes_to_check_for_bad_words
      self.send('attributes_to_check_for_bad_words='.to_sym, fields)
      
      validate :check_attributes_for_bad_words, options
    end
  end

  module InstanceMethods
    private 
    
    def check_attributes_for_bad_words
      @bad_words ||= (CustomConfigHandler.instance.bad_words || []).map{|w| w.downcase}
      self.class.attributes_to_check_for_bad_words.each do |attr|
        attr = attr.to_sym
        if self.respond_to?(attr) and self.send("#{attr}?".to_sym) and self.send(attr).is_a?(String)
          value = self.send(attr)
          @bad_words.each do |word|
            self.errors.add(attr, :bad_word, {:word => word}) if value.include?(word)
          end
        end
      end
    end
  end
end
