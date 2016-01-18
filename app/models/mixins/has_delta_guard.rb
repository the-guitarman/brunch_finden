module Mixins::HasDeltaGuard
  def self.included(klass)
    klass.instance_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    def switch_delta_only_for(*fields)
      class_eval "
        def delta=(value)
          new_value = read_attribute(:delta)
          if Rails.version < '3.0.0'
            attributes = #{fields.inspect}
          else
            attributes = #{fields}
          end
          if attributes.any?{|attr| self.changes.include?(attr)}
            unless [0,false].include?(value)
              new_value = value
              write_attribute(:delta, new_value)
            end
          end
        end"
    end
  end
end
