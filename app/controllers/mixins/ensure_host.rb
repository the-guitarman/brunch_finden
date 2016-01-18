# This module redirects requests to any action of 
# - Frontend::FrontendController descendants
# - Backend::BackendController descendants
# to the configured host, if it's necessary.
module Mixins::EnsureHost
  mattr_reader :mobile_host
  mattr_reader :frontend_host
  mattr_reader :backend_host
  
  fec = CustomConfigHandler.instance.frontend_config
  @@mobile_host = "#{fec['SUBDOMAINS']['MOBILE']}.#{fec['DOMAIN']['NAME']}"
  @@frontend_host = fec['DOMAIN']['FULL_NAME']
  @@backend_host = fec['BACKEND']['DOMAIN']
  
  def self.included(controller)
    controller.before_filter(:ensure_host)
  end
  
  private
  
  def ensure_host
    request_host = request.host
    
    if self.is_a?(Mobile::MobileController)
      unless request_host == mobile_host.split(':').first
        redirect_to determine_mobile_host_url, :status => (redirect_status || :found)
        flash.keep
        return false
      end
    elsif self.is_a?(Frontend::FrontendController)
      unless request_host == frontend_host.split(':').first
        redirect_to determine_frontend_host_url, :status => (redirect_status || :found)
        flash.keep
        return false
      end
    elsif self.is_a?(Backend::BackendController)
      unless request_host == backend_host.split(':').first
        redirect_to determine_backend_host_url, :status => (redirect_status || :found)
        flash.keep
        return false
      end
    end
  end
  
  def determine_mobile_host_url
    ret = "#{request.protocol}#{mobile_host}"
    ret += request.fullpath unless request.fullpath == '/'
    return ret
  end
  
  def determine_frontend_host_url
    ret = "#{request.protocol}#{frontend_host}"
    ret += request.fullpath unless request.fullpath == '/'
    return ret
  end
  
  def determine_backend_host_url
    ret = "#{request.protocol}#{backend_host}"
    ret += request.fullpath unless request.fullpath == '/'
    return ret
  end
end
