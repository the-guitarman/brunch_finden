module Mixins::SwitchToDesktop
  def self.included(klass)
    klass.instance_eval do
      if klass.instance_methods.include?(:mobile_device?) or 
         klass.instance_methods.include?('mobile_device?')
        #extend ClassMethods
        include InstanceMethods

        helper_method :desktop_device?

        #before_filter :check_for_desktop

        #layout proc{ |controller| controller.determine_layout }
      end
    end
  end
  
  module InstanceMethods
    def desktop_device?
      not mobile_device?
    end
    
    #def determine_layout
    #  unless desktop_device?
    #    'mobile/standard'
    #  else
    #    'frontend/standard'
    #  end
    #end

    private

    def check_for_desktop
      session[:mobile_override] = params[:mobile] if params[:mobile]
      return true if redirected?
    end
    
    def redirected?
      ret = false
      
      unless Rails.env.development?
        host = request.host
      else
        host = request.host_with_port
      end
      
      if desktop_device?
        if domain = @frontend_config.seek('DOMAIN', 'FULL_NAME')
          unless domain == host
            redirect_to(new_url(domain))
            ret = true
          end
        end
      end
      
      return ret
    end
    
    def new_url(host)
      ret = "#{request.protocol}#{host}"
      ret += request.fullpath unless request.fullpath == '/'
      return ret
    end
  end
end