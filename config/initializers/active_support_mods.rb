require 'set'

ver = Rails::VERSION
if ver::MAJOR <= 2 and ver::MINOR <= 3 and ver::TINY <= 8

  module ActiveSupport #:nodoc:
    module CoreExtensions #:nodoc:
      module Hash #:nodoc:
        module Except
          def only(*onlies)
            result = self.class.new(@klass)

            onlies.each do |only|
              if self.has_key?(only)
                result[only] = self[only]
              end
            end

            result
          end
        end
      end
    end
  end

end