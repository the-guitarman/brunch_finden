module Mixins::SwitchToMobile
  def self.included(klass)
    klass.instance_eval do
      if klass.instance_methods.include?(:mobile_device?) or 
         klass.instance_methods.include?('mobile_device?')
        #extend ClassMethods
        include InstanceMethods

        helper_method :mobile_device?

        #before_filter :check_for_mobile

        #layout proc{ |controller| controller.determine_layout }
      end
    end
  end
  
  module InstanceMethods
    #def determine_layout
    #  if mobile_device?
    #    'mobile/standard'
    #  else
    #    'frontend/standard'
    #  end
    #end

    private

    def check_for_mobile
      if params[:mobile] == 'off'
        session[:mobile_override] = params[:mobile]
        params.except!(:mobile)
        uri = URI.parse("#{request.protocol}#{host}#{request.fullpath}")
        uri.query = uri.query.gsub('mobile=off', '')
        uri.query = nil if uri.query.blank?
        #puts "--: #{"#{request.protocol}#{host}#{request.fullpath}"} => #{uri.to_s}"
        redirect_to(uri.to_s, {:status => 301})
        return true
      end
      return true if redirected?
    end
    
    def redirected?
      ret = false
      
      if mobile_device?
        if subdomain = @frontend_config.seek('SUBDOMAINS', 'MOBILE')
          if File.exist?("#{Rails.root}/app/views/mobile/#{controller_name}")
            controller_klass_name = self.class.name
            controller_klass = "Mobile::#{controller_klass_name.split('::').last}".constantize
            if controller_klass.instance_methods.include?(action_name.to_s) or 
               controller_klass.instance_methods.include?(action_name.to_s.to_sym)
              domain = "#{subdomain}.#{@host_name}"
              unless domain == host
                redirect_to(new_url(domain))
                ret = true
              end
            end
          end
        end
      end
      
      return ret
    end
    
    def host
      unless Rails.env.development?
        host = request.host
      else
        host = request.host_with_port
      end
    end
    
    def new_url(host)
      ret = "#{request.protocol}#{host}"
      ret += request.fullpath unless request.fullpath == '/'
      return ret
    end
  end
end