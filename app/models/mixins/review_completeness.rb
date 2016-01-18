module Mixins::ReviewCompleteness
  MIN_WORDS_FOR_REVIEW = 20
  
  TOKENIZER = Proc.new{|value| value.to_s.split(' ')}
  
  TEXT_FIELD = :text
  
  COMPLETENESS = {
    :numericality => [:value],
    
    # An array of attributes 
    :presence => [TEXT_FIELD], 
    
    # A hash of :field_name => :minimum_field_length pairs
    :length => {
      TEXT_FIELD => MIN_WORDS_FOR_REVIEW
    }
  }
  
  def self.included(klass)
    klass.instance_eval do
      include InstanceMethods
      
      before_validation :clean_text_attributes_to_validate_length_of
      
      validates_presence_of TEXT_FIELD
      validates_length_of TEXT_FIELD, 
        :minimum   => MIN_WORDS_FOR_REVIEW, 
        :tokenizer => TOKENIZER,
        :if => "#{TEXT_FIELD}?".to_sym
    end
  end

  module InstanceMethods
    def completeness_notes
      ret = {}
      COMPLETENESS.each do |check, fields|
        case check
        when :numericality
          Mixins::ReviewCompleteness.check_numericality(self, fields, ret)
        when :presence
          Mixins::ReviewCompleteness.check_presence(self, fields, ret)
        when :length
          Mixins::ReviewCompleteness.check_words_to_write(self, fields, ret)
        end
      end
      return ret
    end
    
    def words_to_write
      return Mixins::ReviewCompleteness.words_to_write(self, COMPLETENESS[:length])
    end
    
    private
    
    def clean_text_attributes_to_validate_length_of
      COMPLETENESS[:length].keys.each do |field_name|
        self.send(
          "#{field_name}=".to_sym, 
          Mixins::ReviewCompleteness.clean_text_value(self, field_name)
        )
      end
    end
  end
    
  def self.check_presence(object, fields, ret)
    fields.each do |field_name|
      if Mixins::ReviewCompleteness.clean_text_value(object, field_name).blank?
        add_message(ret, field_name, 
          ActiveModel::Errors.new(object).generate_message(field_name, :blank)
        )
      end
    end
  end
    
  def self.check_numericality(object, fields, ret)
    fields.each do |field_name|
      value = object.send(field_name).to_s
      if value.blank? or not value.is_numeric?
        type = 'not_a_number'
        if object.destination
          type = "#{type}_for_#{object.destination.class.base_class.name.underscore}"
        end
        add_message(ret, field_name, 
          ActiveModel::Errors.new(object).generate_message(field_name, type.to_sym)
        )
      end
    end
  end

  def self.check_words_to_write(object, fields, ret)
    words_to_write(object, fields).each do |field_name, field_length_todo|
      length_todo = nil
      if field_length_todo.is_a?(Proc)
        length_todo = field_length_todo.call(object)
      else
        length_todo = field_length_todo
      end
      if length_todo > 0
        add_message(ret, field_name, 
          ActiveModel::Errors.new(object).generate_message(
            field_name, :too_short_note, {:count => (length_todo)}
          )
        )
      end
    end
  end
  
  def self.words_to_write(object, fields)
    ret = {}
    fields.each do |field_name, min_field_length|
      number_of_words = number_of_words(object, field_name)
      min_length = min_field_length.is_a?(Proc) ? min_field_length.call(object) : min_field_length
      if number_of_words < min_length
        ret[field_name] = (min_length - number_of_words)
      else
        ret[field_name] = 0
      end
    end
    return ret
  end
  
  def self.number_of_words(object, field_name)
    value = Mixins::ReviewCompleteness.clean_text_value(object, field_name).to_s
    return TOKENIZER.call(value).length
  end
  
  def self.add_message(ret, field, message)
    ret[field] = ret.key?(field) ? ret[field] << message : [message]
  end
  
  def self.clean_text_value(object, field_name)
    ret = object.send(field_name).to_s
    if object.respond_to?("clean_text_for_#{field_name}".to_sym)
      ret = object.send("clean_text_for_#{field_name}".to_sym)
    end
    return ret
  end
end
