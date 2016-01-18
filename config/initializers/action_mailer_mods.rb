module ActionMailer
  class Base
    cattr_reader :administrators
    cattr_reader :local_server_name
    cattr_reader :domain_name
    cattr_reader :full_domain_name
    
    if Rails.version >= '3.0.0'
      include Rails.application.routes.url_helpers
    else
      include ActionController::UrlWriter
    end
    
    fec = CustomConfigHandler.instance.frontend_config
    @@administrators = fec['EMAIL']['SUPPORT']
    @@local_server_name = `hostname`.strip
    @@domain_name = fec['DOMAIN']['NAME']
    #@@domain_name = fec['DOMAIN']['NAME'].to_s.strip.split(':').first.downcase
    @@full_domain_name = fec['DOMAIN']['FULL_NAME']
    #@@full_domain_name = fec['DOMAIN']['FULL_NAME'].to_s.strip.split(':').first.downcase
    
    # The mailer needs a host to be able to send emails.
    fec = CustomConfigHandler.instance.frontend_config
    self.default_url_options[:host] = fec['DOMAIN']['FULL_NAME'].downcase

    # smtp configuration
    self.smtp_settings.merge!({
      :enable_starttls_auto => false
    })
  end
end
