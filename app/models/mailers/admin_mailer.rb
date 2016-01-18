class Mailers::AdminMailer < ActionMailer::Base
  def report_error(error_message)
    recipients    administrators
    from          "Noreply <noreply@#{domain_name}>"
    reply_to      "Noreply <noreply@#{domain_name}>"
    content_type  'text/plain'
    subject       I18n.translate('mailers.admin_mailer.report_error.subject', {:domain_name => domain_name})
    body          :error_message => error_message
  end
  
  def report_search_queries(message)
    recipients    administrators
    from          "Noreply <noreply@#{domain_name}>"
    reply_to      "Noreply <noreply@#{domain_name}>"
    content_type  'text/plain'
    subject       I18n.translate('mailers.admin_mailer.report_search_queries.subject', {:domain_name => domain_name})
    body          :message => message
  end
end
