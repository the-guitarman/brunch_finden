module Mixins::MobileDeviceDetector
  def self.included(klass)
    klass.instance_eval do
      #extend ClassMethods
      include InstanceMethods
      
      helper_method :mobile_device?
    end
  end
  
  module InstanceMethods
    def mobile_device?
      if session[:mobile_override]
        session[:mobile_override] == "1"
      else
        # Season this regexp to taste. I prefer to treat iPad as non-mobile.
        (request.user_agent =~ /iPhone|iPod|Android|webOS|Mobile/) and (request.user_agent !~ /iPad/)
      end
    end
  end
end