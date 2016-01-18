module Mixins::SecureCode
  def self.included(klass)
    klass.instance_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end

  module ClassMethods
    def secure_code_for(*attr)
      cattr_accessor :secure_code_fields
      self.secure_code_fields = attr.map{|a| a.to_sym}
      
      attr.each do |field|
        eval("before_create :secure_code_for_#{field}")
        
        class_eval "
          def secure_code_for_#{field}
            self.#{field} = SecureRandom.base64(15).tr('+/=', '').strip.delete(\"\n\")
          end
        
          def secure_code_for_#{field}!
            self.secure_code_for_#{field}
            self.save
          end"
      end
    end
  end
  
  module InstanceMethods
    def reset_secure_code_fields
      self.class.secure_code_fields.each do |field|
        eval("self.secure_code_for_#{field}")
      end
    end
    
    def reset_secure_code_fields!
      self.reset_secure_code_fields
      self.save
    end
  end
end
