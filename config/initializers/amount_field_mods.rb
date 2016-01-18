module AmountField #:nodoc:
  module ActiveRecord #:nodoc:
    module Validations
      module ClassMethods

        private

        # we have to read the configuration every time to get the current I18n value
        def format_configuration(configuration)
          format_options = I18n.t(:'number.format', :raise => true) rescue {}
          format_options[:delimiter] = format_options[:delimiter] || ','
          format_options[:separator] = format_options[:separator] || '.'

          # update it with a maybe given default configuration
          format_options = format_options.merge(AmountField::ActiveRecord::Validations.configuration)
          # update it with a maybe given explicit configuration via the macro
          format_options.update(configuration)
        end
      end
    end
  end
end

format = I18n.t(:'number.currency.format.format', :raise => true) rescue ''
if format.match(/^%n.*%u$/)
  AmountField::Configuration.css_class = 'amount_field align-right'
else
  AmountField::Configuration.css_class = 'amount_field'
end
