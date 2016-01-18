# encoding: utf-8
class Mailers::Frontend::FrontendUserMailer < Mailers::Frontend::FrontendMailer
#  default({
#      :bcc      => administrators,
#      :from     => "Noreply <noreply@#{domain_name}>",
#      :reply_to => "Noreply <noreply@#{domain_name}>"
#      :charset  => 'UTF-8',
#      :content_type => 'text/plain'
#  })

  def confirmation_code(user)
    recipients user.email
    bcc      administrators
    from     "Noreply <noreply@#{domain_name}>"
    reply_to "Noreply <noreply@#{domain_name}>"
    subject  I18n.translate('mailers.frontend.frontend_user_mailer.confirmation_code.subject')
    charset 'UTF-8'
    content_type 'text/plain'
    body :mc => BackgroundConfigHandler.instance.model_config,
         :user => user,
         :domain_name => domain_name
  rescue
    deliver_email_error(user)
  end

  def confirmation_reminder(user)
    number = Mixins::AccountReminder.confirmation_reminder_days(FrontendUser).length -
      (user.confirmation_reminders_to_send - 1)
    
    recipients user.email
    bcc      administrators
    from     "Noreply <noreply@#{domain_name}>"
    reply_to "Noreply <noreply@#{domain_name}>"
    subject  I18n.translate('mailers.frontend.frontend_user_mailer.confirmation_reminder.subject',
               {:number => number, :domain_name => domain_name })
    charset 'UTF-8'
    content_type 'text/plain'
    body :user => user, 
         :domain_name => domain_name
  rescue
    deliver_email_error(user)
  end

  def email_confirmation_code(user)
    recipients user.new_email
    bcc      administrators
    from     "Noreply <noreply@#{domain_name}>"
    reply_to "Noreply <noreply@#{domain_name}>"
    subject  I18n.translate('mailers.frontend.frontend_user_mailer.email_confirmation_code.subject',
               {:domain_name => domain_name})
    charset 'UTF-8'
    content_type 'text/plain'
    body :user => user, 
         :domain_name => domain_name
  end

  def password_reset_instructions(user)
    recipients user.email
    bcc      administrators
    from     "Noreply <noreply@#{domain_name}>"
    reply_to "Noreply <noreply@#{domain_name}>"
    subject  I18n.translate('mailers.frontend.frontend_user_mailer.password_reset_instructions.subject',
               {:domain_name => domain_name})
    charset 'UTF-8'
    content_type 'text/plain'
    body :user => user, 
         :domain_name => domain_name
  end

  private

  def deliver_email_error(user)
    user.confirmation_reminders_to_send += 1
    user.save
    raise
  end
end
