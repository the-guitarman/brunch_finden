module RequestParameters
  CITY_CHAR_PARAMETER = :cc
  FIRST_LETTER = :fl
  FIRST_LETTERS = {:all => I18n.t('shared.all'), :'0-9' => '0-9', :'A-Z' => ('A'..'Z').sort}
  
  def self.included(klass)
    klass.instance_eval do
      #extend ClassMethods
      include InstanceMethods
      
      if klass.name.start_with?('Frontend::Frontend') or 
         klass.name.start_with?('Mobile::Mobile')
        helper_method :city_char_parameter, :first_letter_parameter
      end
    end
  end
  
  module InstanceMethods  
    def city_char_parameter
      CITY_CHAR_PARAMETER
    end
    
    def first_letters_parameter
      FIRST_LETTERS
    end
    
    def first_letter_parameter
      FIRST_LETTER
    end
  end
end