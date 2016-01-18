class BaseSweeper < ActionController::Caching::Sweeper
  if Rails.version >= '3.0.0'
    include Rails.application.routes.url_helpers
  else
    include ActionController::UrlWriter
  end
  include RewriteRoutes
  
  @@fec = CustomConfigHandler.instance.frontend_config
  default_url_options[:host] = @@fec['DOMAIN']['FULL_NAME']
  default_url_options[:subdomains] = ['www']
  default_url_options[:namespace] = nil
  
  include LibExpireCaches
  include RequestParameters
  include ActionCacheKey
  include FragmentCacheKey
end