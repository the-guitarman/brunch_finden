class Mailers::Frontend::LocationMailer < Mailers::Frontend::FrontendMailer
  include RewriteRoutes
  
  def confirm_location(location)
    frontend_user = location.frontend_user
    locations_unconfirmed = Location.unpublished.find(:all, :conditions => [
      "id <> ? AND frontend_user_id = ?", location.id, frontend_user.id
    ])
    
    recipients    frontend_user.email
    bcc           administrators
    from          "#{full_domain_name} <noreply@#{domain_name}>"
    reply_to      "#{full_domain_name} <noreply@#{domain_name}>"
    content_type  'text/plain'
    subject       I18n.translate('mailers.frontend.location_mailer.confirm_location.subject', {:domain_name => domain_name})
    body          :location => location,
                  :frontend_user => frontend_user, 
                  :locations_unconfirmed => locations_unconfirmed,
                  :domain_name => domain_name, 
                  :domain_full_name => full_domain_name
  end
  
  def confirm_location_image(location_image)
    frontend_user = location_image.frontend_user
    location_images_unconfirmed = LocationImage.unpublished.find(:all, :conditions => [
      "id <> ? AND frontend_user_id = ?", location_image.id, frontend_user.id
    ])
    
    recipients    frontend_user.email
    bcc           administrators
    from          "#{full_domain_name} <noreply@#{domain_name}>"
    reply_to      "#{full_domain_name} <noreply@#{domain_name}>"
    content_type  'text/plain'
    subject       I18n.translate('mailers.frontend.location_mailer.confirm_location_image.subject', {:domain_name => domain_name})
    body          :location_image => location_image,
                  :frontend_user => frontend_user, 
                  :location_images_unconfirmed => location_images_unconfirmed,
                  :domain_name => domain_name, 
                  :domain_full_name => full_domain_name,
                  :location_rewrite_hash => create_rewrite_hash(location_image.location.rewrite)
  end
  
  def report_changes(location, changes)
    @location_rewrite_hash = create_rewrite_hash(location.rewrite)
    
    bcc           administrators
    from          "#{full_domain_name} <noreply@#{domain_name}>"
    reply_to      "#{full_domain_name} <noreply@#{domain_name}>"
    content_type  'text/plain'
    subject       I18n.translate('mailers.frontend.location_mailer.report_changes.subject')
    body          :location => location, :changes => changes
  end
end
