# TODO:
# - sleep within thread
# - timed observer
# - coupon hander observer
# - path forwarding

class BaseObserver < ActiveRecord::Observer
  if Rails.version >= '3.0.0'
    include Rails.application.routes.url_helpers
  else
    include ActionController::UrlWriter
  end
  include RewriteRoutes
  
  fec = CustomConfigHandler.instance.frontend_config
  default_url_options[:host] = fec['DOMAIN']['FULL_NAME']
  
  include LibExpireCaches
  
  include LibForwarding
end