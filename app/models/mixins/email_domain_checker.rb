# This module checks given model attributes for blacklisted email domains.
# It takes the string right of the @ character, strips it and trys to find it
# in the blacklisted domain arrays.
#
# == Usage
#
# Include it in your model class an call acts_as_email_domain_checker with
# the attribute name(s) - each as a symbol or string separated by commas -
# which you wanna validate.
#
# * include Mixins::EmailDomainChecker
# * acts_as_email_domain_checker(:email1, :email2)
module Mixins::EmailDomainChecker
  # load blacklisted email domain array
  bed = CustomConfigHandler.instance.blacklisted_email_domains rescue []
  BLACKLISTED_DOMAINS = bed.map{|ed| ed.downcase}

  # Hook: The class/model, which includes this module,
  # calls this module method, if it will be included to the class/model.
  def self.included(klass)#:nodoc:
    klass.instance_eval do
      extend ClassMethods
    end
  end

  # define all class methods in this module
  # (e.g. Category.my_class_method)
  module ClassMethods
    def acts_as_email_domain_checker(*attributes)
      if attributes.empty?
        raise("Missing attribute(s) for acts_as_email_domain_checker")
      else
        class_eval "
          validates_each #{attributes.map{|a| ":#{a}"}.join(',')} do |record, attr, value|
            validate_email(record, attr, value)
          end
        "
      end
    end

    def validate_email(record, attr, value)
      email = value.to_s
      if (not email.blank?) and email.include?('@')
        parts = email.split('@')
        domain = parts.last.to_s.strip

        if BLACKLISTED_DOMAINS.include?(domain.downcase)
          record.errors.add(attr, :email_domain_exclusion, :domain => domain)
        end
      end
    end
  end
end