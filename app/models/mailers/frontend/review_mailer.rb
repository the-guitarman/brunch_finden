# encoding: utf-8
class Mailers::Frontend::ReviewMailer < Mailers::Frontend::FrontendMailer
  include RewriteRoutes
  include ReviewTemplateFinder
  
#  helper Frontend::ReviewsHelper
#  helper Frontend::UserHelper

  def review_locked(review)
#    @review = review
#
#    mc = BackgroundConfigHandler.instance.model_config
#    @review.review_locking.reason = mc['REVIEW']['PREDEFINED_LOCKING_REASONS'][4]
#
#    
#    @review_type = I18n.translate("mailers.frontend.review_mailer.review_type.review")
#    if @review.is_comment
#      @review_type = I18n.translate("mailers.frontend.review_mailer.review_type.comment")
#    end
#    @user = review.frontend_user
#    @item = review.destination
#    @item_type = I18n.translate("mailers.frontend.review_mailer.destination.#{@item.class.name}")
#    @item_name =  @item.name
#    @item_name =  @item.full_name if @item.respond_to?('full_name')
#    @domain_name = domain_name
#    mail({
#      :to       => @user.email,
#      :from     => "Noreply <noreply@#{@domain_name}>",
#      :reply_to => "Noreply <noreply@#{@domain_name}>",
#      :subject  => I18n.translate('mailers.frontend.review_mailer.review_locked.subject',
#                                                  {:review_type => @review_type, :domain_name => domain_name})
#    })
  end

  def review_destroyed(review, reason)
#    @review = review
#    @reason = reason
#    @domain_name = domain_name
#    @review_type = I18n.translate("mailers.frontend.review_mailer.review_type.review")
#    if @review.is_comment
#    	@review_type = I18n.translate("mailers.frontend.review_mailer.review_type.comment")
#    end
#    @user = review.frontend_user
#    @item = review.destination
#    @item_type = I18n.translate("mailers.frontend.review_mailer.destination.#{@item.class.name}")
#    @item_name =  @item.name
#    @item_name =  @item.full_name if @item.respond_to?('full_name')
#    mail({
#      :to       => @user.email,
#      :from     => "Noreply <noreply@#{@domain_name}>",
#      :reply_to => "Noreply <noreply@#{@domain_name}>",
#      :subject  => I18n.translate('mailers.frontend.review_mailer.review_destroyed.subject', 
#                                                    {:review_type => @review_type, :domain_name => domain_name})
#    })
  end

  def confirmation_code(review)
    get_confirmation_variables(review)
    send_confirmation_email('mailers.frontend.review_mailer.confirmation_code.subject')
  end

  def confirmation_reminder(review)
    get_confirmation_variables(review)
    send_confirmation_email('mailers.frontend.review_mailer.confirmation_reminder.subject')
  end
  
  private
  
  def get_confirmation_variables(review)
    @review = review
    @user = review.frontend_user
    conditions = ["id <> ? AND frontend_user_id = ? ", review.id, review.frontend_user_id]
    if Rails.version >= '3.0.0'
      @other_unpublished_reviews = Review.unpublished.where(conditions)
    else
      @other_unpublished_reviews = Review.unpublished.find(:all, {:conditions => conditions})
    end
    @item = review.destination
    @location_rewrite_hash = create_rewrite_hash(@item.rewrite)
    @review_template, @review_template_questions = get_review_template_with_questions(review.destination)
    @domain_name = domain_name
    @domain_full_name = full_domain_name
  end
  
  def send_confirmation_email(subject)
    if Rails.version >= '3.0.0'
      mail({
        :to       => @user.email,
        :from     => "Noreply <noreply@#{@domain_name}>",
        :reply_to => "Noreply <noreply@#{@domain_name}>",
        :subject  => I18n.translate(subject, {:item_name => @item.name})
      })
    else
      recipients @user.email
      bcc      administrators
      from     "Noreply <noreply@#{@domain_name}>"
      reply_to "Noreply <noreply@#{@domain_name}>"
      subject  I18n.translate(subject, {:item_name => @item.name})
      charset 'UTF-8'
      content_type 'text/plain'
      body :review => @review,
           :user => @review.frontend_user,
           :other_unpublished_reviews => @other_unpublished_reviews,
           :item => @item,
           :domain_name => @domain_name,
           :domain_full_name => @domain_full_name
    end
  end
end
