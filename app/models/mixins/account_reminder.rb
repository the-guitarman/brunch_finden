#encoding: utf-8

# Sends reminder emails to users every X days, 
# which forgot to confirm their accounts. 
# See BackgroundConfigHandler.instance.model_config:
# - [ModelClass.name]['FORWARD_CONFIRMATION_REMINDER_EMAIL']
# Call:
# - Mixins::AccountReminder.confirmation_reminder_days(ModelClass)
# 
# At the end, not confirmed accounts will be deleted after 
# a configured period of additional X days. 
# See BackgroundConfigHandler.instance.model_config:
# - [ModelClass.name]['DELETE_UNCONFIRMED_X_DAYS_AFTER_LAST_REMINDER_EMAIL']
# Call:
# - Mixins::AccountReminder.confirmation_period(ModelClass)
# 
# Example:
# include Mixins::AccountReminder
#
module Mixins::AccountReminder
  @@account_reminder_models = []
  
  def self.included(klass)
    klass.instance_eval do
      before_create :_set_confirmation_reminders_to_send      
      after_create :_send_confirmation_email
      
      extend ClassMethods
      include InstanceMethods
    end
    @@account_reminder_models.push(klass)
  end

  def self.models_implement_me
    return @@account_reminder_models
  end
  
  module ClassMethods
    def confirmation_period
      Mixins::AccountReminder.confirmation_period(self)
    end
  end

  module InstanceMethods
    def send_confirmation_email
      if self.is_a?(FrontendUser)
        if Rails.version >= '3.0.0'
          Mailers::Frontend::FrontendUserMailer.confirmation_code(self).deliver
        else
          Mailers::Frontend::FrontendUserMailer.deliver_confirmation_code(self)
        end
      end
    end
    
    def send_confirmation_reminder_email
      if self.is_a?(FrontendUser)
        if Rails.version >= '3.0.0'
          Mailers::Frontend::FrontendUserMailer.confirmation_reminder(self).deliver
        else
          Mailers::Frontend::FrontendUserMailer.deliver_confirmation_reminder(self)
        end
      end
    end
    
    private

    def _set_confirmation_reminders_to_send
      unless self.confirmation_reminders_to_send?
        self.confirmation_reminders_to_send = 
          Mixins::AccountReminder.confirmation_reminder_days(self.class).length
      end
    end


    def _send_confirmation_email
      if self.pending? and $migration.blank?
        #self.confirmation_reminders_to_send -= 1
        self.wait_for_confirmation
        self.save
        send_confirmation_email
      end
    end
  end
  
  
  
    
#  def self.create_cronjob
#    # clean up first
#    if job_template = JobTemplate.find_by_name('User Confirmation Reminder')
#      if crontab = Crontab.find_by_job_template_id(job_template.id)
#        crontab.destroy
#      end
#      job_template.destroy
#    end
#    
#    # create the new one
#    unless job_template = JobTemplate.find_by_name('Account Reminder')
#      job_template = JobTemplate.create({
#        :name => 'Account Reminder', :is_a_ruby_job => true,
#        :executable => 'Mixins::AccountReminder.remember_to_confirm',
#        :priority => Job::PRIORITIES[:low],
#        :nice_level => 19, :startable_after_fail => true,
#        :reniceable => true, :restartable => true,
#        :killable => true, :max_memory => 0,
#        :log_file => "account_reminder"
#      })
#    end
#    if job_template and server = Server.select_by_availability
#      unless crontab = Crontab.find_by_job_template_id(job_template.id)
#        crontab = Crontab.create({
#          :server_id => server.id, :job_template_id => job_template.id,
#          :cron => '30 5 * * *', :executable_additional => ''
#        })
#      end
#    end
#  end
  
  def self.remember_to_confirm(options = {})
    show_messages = options[:show_messages].nil? ? true : options[:show_messages]
    
    send_reminder_email = lambda do |ar|
      if ar.is_a?(FrontendUser)
        ar.send_confirmation_reminder_email
      end
      ar.confirmation_reminders_to_send -= 1
      ar.save
      if show_messages
        puts "#{I18n.l(Time.now, {:format => :log_file})}, type: #{ar.class.name}, #{ar.id} => Confirmation reminder email sent!"
      end
    end
    
    now = Time.now
    Mixins::AccountReminder.models_implement_me.each do |model|
      reminder_days = confirmation_reminder_days(model)
      delete_after_days = reminder_days.last + confirmation_period(model)
      
      model.waiting.each do |ar|
        if delete_after_days > 0 and ((now - ar.created_at) / delete_after_days.days).to_i >= 1
          # destroy unconfirmed ar    
          if ar.respond_to?(:destroyable?) and not ar.destroyable?
            # user can't be destroyed
            ar.not_deletable! if ar.respond_to?(:not_deletable!)
            next
          else
            ar.destroy
            if show_messages
              puts "#{I18n.l(Time.now, {:format => :log_file})}, type: #{ar.class.name}, id: #{ar.id} => destroyed!"
            end
          end
        elsif ar.confirmation_reminders_to_send > 0
          # send reminder
          reminder_days.each_with_index do |days, idx|
            if days > 0 and ((now - ar.created_at) / days.days).to_i >= 1 and 
               idx == (reminder_days.length - ar.confirmation_reminders_to_send)
              send_reminder_email.call(ar)
            end
          end
        end
      end
    end
    true
  end
  
  def self.confirmation_reminder_days(klass)
    bch = BackgroundConfigHandler.instance
    bgc = bch.model_config
    klass_name = klass.name.underscore.upcase
    if not bgc[klass_name] or not bgc[klass_name]['FORWARD_CONFIRMATION_REMINDER_EMAIL']
      bgc[klass_name] = bgc[klass_name] || bgc['USER'].copy
      bch.write_model_config(bgc)
    end
    return bgc[klass_name]['FORWARD_CONFIRMATION_REMINDER_EMAIL'].sort
  end

  def self.confirmation_period(klass)
    bch = BackgroundConfigHandler.instance
    bgc = bch.model_config
    klass_name = klass.name.underscore.upcase
    if not bgc[klass_name] or not bgc[klass_name]['DELETE_UNCONFIRMED_X_DAYS_AFTER_LAST_REMINDER_EMAIL']
      bgc[klass_name] = bgc[klass_name] || bgc['USER'].copy
      bch.write_model_config(bgc)
    end
    return confirmation_reminder_days(klass).last + 
      bgc[klass_name]['DELETE_UNCONFIRMED_X_DAYS_AFTER_LAST_REMINDER_EMAIL'].to_i
  end
end