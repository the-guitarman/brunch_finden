# encoding: utf-8
class Mailers::Frontend::FeedbackMailer < Mailers::Frontend::FrontendMailer
  #default({:from => "feedback-button@#{domain_name}"})
  
  def feedback_mail(user_name, user_email, message)
    @user_name, @user_email, @message = user_name, user_email, message
    if Rails.version >= '3.0.0'
      mail({
        :to => "feedback@#{domain_name}", 
        :subject => "Feedback - #{domain_name}"
      })
    else
      recipients @user_email
      bcc      administrators
      from     "Noreply <noreply@#{domain_name}>"
      reply_to "Noreply <noreply@#{domain_name}>"
      subject  "Feedback - #{domain_name}"
      charset 'UTF-8'
      content_type 'text/plain'
      body :user_name => @user_name,
           :user_email => @user_email,
           :message => @message
    end
  end
end