#encoding: utf-8

# You can include this module in your model to clean text from ugly ascii sequences.
#
# Example:
# include Mixins::TextDublicateChecker
# text_dublicate_check_for(:my_text_field_1, :my_text_field_2, {
#   :action_comparer => {
#     ActionComparer initialize options hash, 
#     please see: http://rubydoc.info/gems/ActionText/1.2.0/ActionComparer
#   },
#   :check_against   => Proc.new {|self|
#     A proc object to call, which returns a string or 
#     an array of strings to check against these strings. 
#     The proc will be called with the current object instance
#     as the first and only parameter.
#   }
# })
#

require 'action_text'

module Mixins::TextDublicateChecker
  def self.included(klass)
    klass.instance_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end
  
  module ClassMethods
    # Adds clean_<field_name> method to model
    # field must be a String or a Symbol
    def text_dublicate_check_for(*fields)
      options = fields.extract_options!
      
      ac_params = options[:action_comparer]
      raise 'There are no action comparer initialize parameters.' unless ac_params
      
      ca_proc   = options[:check_against]
      raise 'There is no proc to check text attribute against it.' unless ca_proc
      
      fields = fields.map{|f| f.to_s}.compact.uniq
      fields.delete_if{|f| f.blank?}
      raise 'There are no fields to clean.' if fields.empty?
      
      fields.each do |field|
        class_eval("cattr_accessor :action_comparer_params_for_#{field}")
        self.send("action_comparer_params_for_#{field}=".to_sym, ac_params)
        
        class_eval("cattr_accessor :check_against_proc_for_#{field}")
        self.send("check_against_proc_for_#{field}=".to_sym, ca_proc)
        
        class_eval("validate :text_dublicate_check_for_#{field}")
        class_eval "
          def text_dublicate_check_for_#{field} 
            acp = self.class.action_comparer_params_for_#{field}
            acp = init_action_comparer_params(acp)
            cap = self.class.check_against_proc_for_#{field}
            too_similar_texts = self.text_dublicate_check(self.#{field}.to_s, acp, cap)
            if too_similar_texts.length > 0
              self.errors.add(:#{field}, :too_similar)
            end
          end"
      end
    end
  end

  module InstanceMethods
    def text_dublicate_check(text, acp, cap)
      ac = ActionComparer.new(acp)
      return ac.too_similar_texts(text.to_s, cap.call(self).to_a)
    end
    
    private 
    
    def init_action_comparer_params(acp)
      ret = {}
      acp.each do |k,v|
        if v.is_a?(Proc)
          ret[k] = v.call(self)
        else
          ret[k] = v
        end
      end
      return ret
    end
  end
end
