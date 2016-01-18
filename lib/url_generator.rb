class UrlGenerator
  if Rails.version >= '3.0.0'
    include Rails.application.routes.url_helpers
  else
    include ActionController::UrlWriter
  end
  
  def initialize
    fec = CustomConfigHandler.instance.frontend_config
    @@default_url_options = {:host => fec['DOMAIN']['FULL_NAME']}
  end
  
  def method_missing(name, *args)
    self.send(name, *args)
  end
end