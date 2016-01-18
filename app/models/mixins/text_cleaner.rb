#encoding: utf-8

# You can include this module in your model to clean text from ugly ascii sequences.
#
# Example:
# include Mixins::TextCleaner
# clean_text_in(:my_text_field_1, :my_text_field_2, {
#   :action_formatter => {
#     ActionFormatter initialize options,
#     please see: http://rubydoc.info/gems/ActionText/1.2.0/ActionFormatter
#   }
# })
#

require 'action_text'
require 'nokogiri'

module Mixins::TextCleaner
  def self.included(klass)
    klass.instance_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end
  
  module ClassMethods
    # Adds clean_<field_name> method to model
    # field must be a String or a Symbol
    def clean_text_in(*fields)
      options = fields.extract_options!
      
      af_params = options[:action_formatter]
      raise 'There are no action formatter initialize parameters.' unless af_params
      
      fields = fields.map{|f| f.to_s}.compact.uniq
      fields.delete_if{|f| f.blank?}
      raise 'There are no fields to clean.' if fields.empty?
      
      fields.each do |field|
        class_eval("cattr_accessor :action_formatter_params_for_#{field}")
        self.send("action_formatter_params_for_#{field}=".to_sym, af_params)
        
        class_eval("before_validation :clean_text_in_#{field}")
        
        valid_html_only = ''
        if options[:valid_html_only] == true
          valid_html_only += "self.#{field} = clean_html_handler(self.#{field}.to_s)"
        end
        
        class_eval "
          def clean_text_in_#{field}
            afp = self.class.action_formatter_params_for_#{field}
            afp = init_action_formatter_params_handler(afp)
            self.#{field} = clean_text_handler(self.#{field}.to_s, afp)
            #{valid_html_only}
            true
          end"
      end
    end
  end

  module InstanceMethods
    
    private 
    
    def clean_html_handler(text)
      doc  = Nokogiri::HTML.parse(text)
      return doc.search('body').children.to_html
    end
    
    def clean_text_handler(text, afp)
      af = ActionFormatter.new(afp)
      text = af.parse(text.to_s)
      return text.strip
    end
    
    def init_action_formatter_params_handler(afp)
      ret = {}
      afp.each do |k,v|
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
