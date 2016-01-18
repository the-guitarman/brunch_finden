# Module can be used for UserGeneratedContent. It handles confirmation emails
# for content. 
module Mixins::UserGeneratedContent
  @@user_generated_content_models=[] 
  def self.included(klass)
    klass.instance_eval do
      belongs_to :frontend_user
      validates_presence_of :frontend_user
      
      before_create :set_confirmation_reminders_to_send
  
      #extend ClassMethods
      include InstanceMethods
    end
    @@user_generated_content_models.push klass
  end

  def self.models_implement_me
    @@user_generated_content_models
  end

  module InstanceMethods
    def set_confirmation_reminders_to_send
      mc = BackgroundConfigHandler.instance.model_config
      self.confirmation_reminders_to_send = mc['FRONTEND_USER']['GENERATED_CONTENT']['FORWARD_CONFIRMATION_REMINDER_EMAIL'].length
    end
  end

  #module ClassMethods
  #end

  # Sends a reminder email to users, which have not confirmed their ratings or
  # delete their ratings after a given timeout.
  def self.remember_to_confirm(options = {})
    show_messages = options[:show_messages].nil? ? true : options[:show_messages]
    bgc = BackgroundConfigHandler.instance.model_config
    reminder_days = bgc['FRONTEND_USER']['GENERATED_CONTENT']['FORWARD_CONFIRMATION_REMINDER_EMAIL'].sort
    delete_after_days = reminder_days.last + bgc['FRONTEND_USER']['GENERATED_CONTENT']['DELETE_UNCONFIRMED_X_DAYS_AFTER_LAST_REMINDER_EMAIL'].to_i
    send_reminder_email = lambda do |ugc|
      if Rails.version >= '3.0.0'
        Mailers::Frontend::ReviewMailer.confirmation_reminder(ugc).deliver
      else
        Mailers::Frontend::ReviewMailer.deliver_confirmation_reminder(ugc)
      end
      if show_messages
        puts "#{I18n.l(Time.now, {:format => :log_file})}: frontend user id: #{ugc.frontend_user.id}, " +
        "login: #{ugc.frontend_user.login} => Confirmation reminder email sent."
      end
    end
    now = Time.now
    Mixins::UserGeneratedContent.models_implement_me.each do |model|
      #model.where({:state => 'unpublished'}).each do |ugc|
      model.find(:all, {:conditions => {:state => 'unpublished'}}).each do |ugc|
        if delete_after_days > 0 and
          ((now - ugc.created_at) / delete_after_days.days).to_i == 1
          # destroy unconfirmed ugc
          ugc.destroy
          if show_messages
            puts "#{I18n.l(Time.now, {:format => :log_file})}: type #{ugc.class.name} id: #{ugc.id}, " +
            "frontend-user-id: #{ugc.frontend_user_id} " 
          end
        else
          # send reminder
          reminder_days.each do |days|
            if (days > 0 and
                (((now - ugc.created_at) / days.days).to_i == 1) and
                (ugc.confirmation_reminders_to_send > 0))
                send_reminder_email.call(ugc)
                ugc.confirmation_reminders_to_send -= 1
                ugc.save
            end
          end
        end
      end
    end
    nil
  end
end
