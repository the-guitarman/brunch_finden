module Mixins::PolymorphicFinder
  def self.included(klass)
    klass.instance_eval do
      def self.polymorphic_finder_for(assoc)
        if Rails.version >= '3.0.0'
          class_eval("scope :#{assoc}, lambda {|o| where(:#{assoc}_type=>o.class.base_class.name,:#{assoc}_id=>o.id)}")
        else
          class_eval("named_scope :#{assoc}, lambda {|o| {:conditions => {:#{assoc}_type => o.class.base_class.name, :#{assoc}_id => o.id}}}")
        end
      end
    end
  end
end
