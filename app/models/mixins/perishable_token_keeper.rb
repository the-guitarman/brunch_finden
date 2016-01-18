#encoding: utf-8

# You can include this module into your authlogic account model after the 
# acts_as_authentic block. This is helpful to let not change the 
# perishable_token for the account in these cases:
# - account is waiting for confirmation
# - account is changing the email
# - account keeps the token manually (account.keep_perishable_token = true)
#
# Example:
# include Mixins::PerishableTokenKeeper

module Mixins::PerishableTokenKeeper
  def self.included(klass)
    if klass.is_model_class?
      return if !klass.column_names.include?("perishable_token")
      klass.instance_eval do
        #extend ActiveRecordBaseClassMethods
        alias_method(:original_disable_perishable_token_maintenance?, :disable_perishable_token_maintenance?)
        include ActiveRecordBaseInstanceMethods
      end
    elsif klass.superclass == Authlogic::Session::Base
      klass.instance_eval do
        #extend AuthlogicSessionBaseClassMethods
        alias_method(:original_validate_magic_states, :validate_magic_states)
        alias_method(:original_reset_perishable_token!, :reset_perishable_token!)
        include AuthlogicSessionBaseInstanceMethods
      end
    end
  end
  
  #module ActiveRecordBaseClassMethods
  #end

  module ActiveRecordBaseInstanceMethods  
    def keep_perishable_token
      @keep_perishable_token
    end

    def keep_perishable_token=(value)
      @keep_perishable_token = value
    end

    # overwrite authlogic method, so that the users perishable token
    # can't change, if its waiting for confirmation of its registration or a new email
    def disable_perishable_token_maintenance?
      if (self.respond_to?(:waiting?) and self.waiting?) or 
         (self.respond_to?(:changing_email?) and self.changing_email?) or 
         @keep_perishable_token == true
        ret = true
      else
        ret = original_disable_perishable_token_maintenance?
      end
      return ret
    end
  end
  
  #module AuthlogicSessionBaseClassMethods
  #end
  
  module AuthlogicSessionBaseInstanceMethods
  
    private

    # Extend authlogic method validate_magic_states,
    # to extend magic_states with :waiting and :blocked for confirmation.
    # Waiting users can login to their accounts.
    def validate_magic_states
      if (attempted_record.respond_to?("#{:waiting}?") and attempted_record.send("#{:waiting}?")) or
         (attempted_record.respond_to?("#{:changing_email}?") and attempted_record.send("#{:changing_email}?")) or 
         (attempted_record.respond_to?(:keep_perishable_token) and attempted_record.keep_perishable_token == true)
        return true
      elsif attempted_record.respond_to?("#{:blocked}?") and attempted_record.send("#{:blocked}?")
        self.errors.clear
        self.errors.add(
          :base, 
          I18n.t("authlogic.error_messages.#{:blocked}", {:default => "Your account is #{:blocked} at the moment"})
        )
        return false
      else
        original_validate_magic_states
      end
    end

    # Overwrite authlogic method reset_perishable_token!,
    # so that the users perishable token can't change,
    # if its waiting for confirmation
    def reset_perishable_token!
      if (record.respond_to?("#{:waiting}?") and record.send("#{:waiting}?") == false) and
         (record.respond_to?("#{:changing_email}?") and record.send("#{:changing_email}?") == false) and
         (record.respond_to?("#{:keep_perishable_token}") and record.send("#{:keep_perishable_token}") != true)
        original_reset_perishable_token!
      end
    end
  end
end
