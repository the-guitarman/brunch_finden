class Mailers::Frontend::LocationSuggestionMailer < Mailers::Frontend::FrontendMailer
  def location_suggestion(location_suggestion)
    #recipients    user.email
    bcc           administrators
    from          "#{full_domain_name} <noreply@#{domain_name}>"
    reply_to      "#{full_domain_name} <noreply@#{domain_name}>"
    content_type  'text/plain'
    subject       I18n.translate('mailers.frontend.location_suggestion_mailer.location_suggestion.subject', {:domain_name => domain_name})
    body          :location_suggestion => location_suggestion
  end
end
