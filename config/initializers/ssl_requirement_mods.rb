if defined?(SslRequirement)
  module SslRequirement 
    puts "== INIT: Ssl Requirement"
    fec = CustomConfigHandler.instance.frontend_config

    # for mor information about configuration, view helpers and testing 
    # please see: https://github.com/bartt/ssl_requirement

    # Redirects to https://secure.example.com instead of the default
    # https://www.example.com.
    if secure_subdomain = fec['SUBDOMAINS']['SECURE'] and not secure_subdomain.blank?
      SslRequirement.ssl_host = "#{secure_subdomain}.#{fec['DOMAIN']['NAME'].split(':').first}"
    end

    # Redirects to http://nonsecure.example.com instead of the default
    # http://www.example.com.
    #SslRequirement.non_ssl_host = 'nonsecure.example.com'

    # You are able to the change the status code (defaults to 302) of the redirect.
    SslRequirement.redirect_status = :moved_permanently

    # You are able to turn disable ssl redirects by adding the following environment configuration file:
    #SslRequirement.disable_ssl_check = true

    protected

    # Method extended to:
    # - don't suppose to run as SSL in non production environments
    # - require or except all actions to run as SSL
    def ssl_required?
      return false if non_production_environment?

      required = (self.class.read_inheritable_attribute(:ssl_required_actions) || [])
      except  = (self.class.read_inheritable_attribute(:ssl_required_except_actions) || [])

      unless except
        required.include?(action_name.to_sym) or required.include?(:all)
      else
        !(except.include?(action_name.to_sym) or except.include?(:all))
      end
    end

    private

    def non_production_environment?
      environment = Rails.env.to_s
      ret = (environment == 'development' or 
        environment.end_with?('_dev') or
        environment == 'test')
      return ret
    end

    def determine_host_and_port(request, ssl)
      request_host = request.host
      request_port = request.port

      if ssl
        if self.is_a?(Backend::BackendController)
          host = request_host
        else
          host = (ssl_host || request_host)
        end
        "#{host}#{determine_port_string(request_port)}"
      else
        "#{(non_ssl_host || request_host)}#{determine_port_string(request_port)}"
      end
    end
  end

#  # Set secure subdomain
#  Revolution::Application.configure do
#    config.after_initialize do
#  #    puts "== INIT: Ssl Requirement"
#      fec = CustomConfigHandler.instance.frontend_config
#
#      # for mor information about configuration, view helpers and testing 
#      # please see: https://github.com/bartt/ssl_requirement
#
#      # Redirects to https://secure.example.com instead of the default
#      # https://www.example.com.
#      if secure_subdomain = fec['SUBDOMAINS']['SECURE'] and not secure_subdomain.blank?
#        SslRequirement.ssl_host = "#{secure_subdomain}.#{fec['DOMAIN']['NAME'].split(':').first}"
#      end
#
#      # Redirects to http://nonsecure.example.com instead of the default
#      # http://www.example.com.
#      #SslRequirement.non_ssl_host = 'nonsecure.example.com'
#
#      # You are able to the change the status code (defaults to 302) of the redirect.
#      SslRequirement.redirect_status = :moved_permanently
#
#      # You are able to turn disable ssl redirects by adding the following environment configuration file:
#      #SslRequirement.disable_ssl_check = true
#    end
#  end
end
