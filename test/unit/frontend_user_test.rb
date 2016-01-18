#encoding: utf-8
require 'test_helper'

class FrontendUserTest < ActiveSupport::TestCase
  should have_many(:locations)
  should have_many(:reviews)
  
  #should validate_presence_of(:name).with_message(/What's your name\?/)
  #should validate_presence_of(:email).with_message(/Please type the your email\?/)
  
  # process before each test method
  def setup
    
  end

  # process before each test method
  def teardown

  end
  
  def test_create
    FrontendUser.delete_all
    ActionMailer::Base.deliveries = []

    test_fu_1 = FrontendUser.create
    assert test_fu_1.pending?
    assert test_fu_1.salutation.blank?
    assert_equal 'undefined', test_fu_1.gender
    assert test_fu_1.errors[:login].any?
    assert !test_fu_1.errors[:first_name].any?
    assert !test_fu_1.errors[:name].any?
    assert test_fu_1.errors[:email].any?
    assert test_fu_1.errors[:password].any?
    assert test_fu_1.errors[:password_confirmation].any?
    assert ActionMailer::Base.deliveries.empty?

    attributes = valid_attributes({
      :name => 'J.',
      :email => 'michael@.com',
      :password => nil
    })
    test_fu_2 = FrontendUser.create(attributes)
    assert test_fu_2.pending?
    assert test_fu_2.salutation.blank?
    assert_equal 'undefined', test_fu_2.gender
    assert !test_fu_2.errors[:login].any?
    assert !test_fu_2.errors[:first_name].any?
    assert !test_fu_2.errors[:name].any?
    assert test_fu_2.errors[:email].any?
    assert test_fu_2.errors[:password].any?
    assert !test_fu_2.errors[:password_confirmation].any?
    assert ActionMailer::Base.deliveries.empty?

    attributes[:login] = -1
    attributes[:email] = 'micheal@jackson.com'
    attributes[:password] = 'other-pw'
    test_fu_3 = FrontendUser.create(attributes)
    assert test_fu_3.pending?
    assert test_fu_3.errors[:login].any?
    assert !test_fu_3.errors[:first_name].any?
    assert !test_fu_3.errors[:name].any?
    assert !test_fu_3.errors[:email].any?
    assert test_fu_3.errors[:password].any?
    assert !test_fu_3.errors[:password_confirmation].any?
    assert ActionMailer::Base.deliveries.empty?

    # all ok and confirmation email send
    attributes = valid_attributes({:salutation => 'Mr'})
    frontend_user_1 = FrontendUser.create(attributes)
    frontend_user_1.reload
    assert frontend_user_1.valid?
    assert frontend_user_1.waiting?
    assert_equal 'Mr', frontend_user_1.salutation
    check_sending_confirmation_email(frontend_user_1, 1)
    
    # use email as login, if login is blank
    attributes = valid_attributes_2({:login => nil, :first_name => nil, :name => nil})
    frontend_user_2 = FrontendUser.new(attributes)
    assert frontend_user_2.save
    frontend_user_2.reload
    assert frontend_user_2.waiting?
    assert_equal attributes[:email], frontend_user_2.login
    assert_equal nil, frontend_user_2.salutation
    assert_equal 'undefined', frontend_user_2.gender
    check_sending_confirmation_email(frontend_user_2, 2)
  end

  def test_constants_and_associations
    # modules
    assert FrontendUser.included_modules.include?(Mixins::AccountReminder)
    assert FrontendUser.included_modules.include?(Mixins::BadWordChecker)
    assert FrontendUser.included_modules.include?(Mixins::Salutation)
    assert FrontendUser.included_modules.include?(AASM)
    #assert FrontendUser.included_modules.include?(Mixins::ActsAsRater)
    assert FrontendUser.included_modules.include?(Mixins::EmailDomainChecker)
    
    # constants
    if Rails.version >= '3.0.0'
      assert FrontendUser.constants.include?(:SALUTATIONS)
    else
      assert FrontendUser.constants.include?('SALUTATIONS')
    end
    assert FrontendUser::SALUTATIONS.is_a?(Array)
    
    if Rails.version >= '3.0.0'
      assert FrontendUser.constants.include?(:STATES)
    else
      assert FrontendUser.constants.include?('STATES')
    end
    states = FrontendUser::STATES
    assert states.is_a?(Hash)
    keys = states.keys
    assert keys.include?(:pending)
    assert keys.include?(:waiting)
    assert keys.include?(:confirmed)
    assert keys.include?(:changing_email)
    assert keys.include?(:blocked)
    assert keys.include?(:anonymized)
    assert keys.include?(:not_deletable)
    
    if Rails.version >= '3.0.0'
      assert FrontendUser.constants.include?(:GENDERS)      
    else
      assert FrontendUser.constants.include?('GENDERS')
    end
    assert FrontendUser::GENDERS.is_a?(Hash)
    assert FrontendUser::GENDERS.key?(:mr)
    assert_equal 'male', FrontendUser::GENDERS[:mr]
    assert FrontendUser::GENDERS.key?(:ms)
    assert_equal 'female', FrontendUser::GENDERS[:ms]
    assert FrontendUser::GENDERS.key?(nil)
    assert_equal 'undefined', FrontendUser::GENDERS[nil]
    
    if Rails.version >= '3.0.0'
      assert FrontendUser.constants.include?(:DEFAULT_GENDER)
    else
      assert FrontendUser.constants.include?('DEFAULT_GENDER')
    end
    assert FrontendUser::DEFAULT_GENDER.is_a?(String)
    assert_equal 'undefined', FrontendUser::DEFAULT_GENDER

    # associations
    FrontendUser.delete_all
    user = FrontendUser.create(valid_attributes)

    assert_respond_to user, :locations
    assert_respond_to user, :reviews
  end

  def test_update
    # create without first name or name is ok.
    attributes = valid_attributes({:first_name => nil, :name => nil})
    frontend_user = FrontendUser.new(attributes)
    assert frontend_user.pending?
    assert frontend_user.save
    assert frontend_user.waiting?
    
    # update without first name or name is not possible.
    assert !frontend_user.valid?
    assert frontend_user.errors[:first_name].any?
    assert frontend_user.errors[:name].any?
    
    # confirm without first name or name is ok.
    frontend_user.confirm!
    assert frontend_user.confirmed?
    
    # update without first name or name is not possible.
    assert !frontend_user.valid?
    assert frontend_user.errors[:first_name].any?
    assert frontend_user.errors[:name].any?
  end

  def test_destroy
    fu = FrontendUser.create(valid_attributes)
    assert fu.valid?
    assert fu.locations.empty?

    location = Location.first
    fu.locations << location
    fu.reload

    # destroy frontend user
    fu.destroy
    assert fu.frozen?
    assert !fu.locations.first.frozen?
    
    # frontend user of location changed 
    location.reload
    domain_name = CustomConfigHandler.instance.frontend_config['DOMAIN']['NAME'].downcase
    assert_equal "info@#{domain_name}", location.frontend_user(true).email
  end

  def test_bad_word_check
    FrontendUser.delete_all
    
    attributes = valid_attributes({
      :login => 'nazi',
      :first_name => 'fascho',
      :name => 'admin',
      :email => 'michael@porno.com'
    })
    frontend_user = FrontendUser.create(attributes)
    
    if Rails.version >= '3.0.0'
      assert frontend_user.errors[:login].any?
      assert_equal 'Your login includes a blacklisted word (nazi).', frontend_user.errors[:login].first

      assert frontend_user.errors[:first_name].any?
      assert_equal 'Your first name includes a blacklisted word (fascho).', frontend_user.errors[:first_name].first

      assert frontend_user.errors[:name].any?
      assert_equal 'Your name includes a blacklisted word (admin).', frontend_user.errors[:name].first

      assert frontend_user.errors[:email].any?
      assert_equal 'Your email includes a blacklisted word (porno).', frontend_user.errors[:email].first
    else
      assert frontend_user.errors[:login].any?
      assert frontend_user.errors[:login].include?('Your login includes a blacklisted word (nazi).')

      assert frontend_user.errors[:first_name].any?
      assert frontend_user.errors[:first_name].include?('Your first name includes a blacklisted word (fascho).')

      assert frontend_user.errors[:name].any?
      assert frontend_user.errors[:name].include?('Your name includes a blacklisted word (admin).')

      assert frontend_user.errors[:email].any?
      assert frontend_user.errors[:email].include?('Your email includes a blacklisted word (porno)')
    end
  end

  def test_remember_to_confirm
    FrontendUser.record_timestamps = false
    
    # prepare the test
    FrontendUser.delete_all
    ActionMailer::Base.deliveries = []
    now = DateTime.now
    confirmation_reminders_to_send = 
      Mixins::AccountReminder.confirmation_reminder_days(FrontendUser).length
    assert_equal 2, confirmation_reminders_to_send
    # create a frontend user
    fu = FrontendUser.create(valid_attributes({:created_at => now, :updated_at => now}))
    assert fu.valid?
    # one email sent on creation ...
    confirmation_reminders_sent = ActionMailer::Base.deliveries.length
    assert_equal 1, confirmation_reminders_sent
#    confirmation_reminders_to_send -= 1
    assert_equal confirmation_reminders_to_send, fu.confirmation_reminders_to_send
    # ..., don't send an email now
    Mixins::AccountReminder.remember_to_confirm({:show_messages => false})
    fu.reload
    assert_equal confirmation_reminders_to_send, fu.confirmation_reminders_to_send
    assert_equal confirmation_reminders_sent, ActionMailer::Base.deliveries.length
    # remember not confirmed users to confirm their accounts
    reminder_days = Mixins::AccountReminder.confirmation_reminder_days(FrontendUser)
    reminder_days.each do |day|      
      # prepare object to send no reminder email after x days
      fu.created_at = (now - ((day - 2).days))
      assert fu.save
      
      # send reminder email
      Mixins::AccountReminder.remember_to_confirm({:show_messages => false})

      fu.reload
      assert_equal confirmation_reminders_to_send, fu.confirmation_reminders_to_send
      assert_equal confirmation_reminders_sent, ActionMailer::Base.deliveries.length
      
      
      # prepare object to send reminder email after x days
      fu.created_at = (now - ((day + 2).days))
      assert fu.save
      
      # send reminder email
      Mixins::AccountReminder.remember_to_confirm({:show_messages => false})
      confirmation_reminders_to_send -= 1
      confirmation_reminders_sent += 1

      fu.reload
      assert_equal confirmation_reminders_to_send, fu.confirmation_reminders_to_send
      assert_equal confirmation_reminders_sent, ActionMailer::Base.deliveries.length
      check_sending_a_reminder_email(fu, confirmation_reminders_sent)

      # don't send reminder email again
      Mixins::AccountReminder.remember_to_confirm({:show_messages => false})

      fu.reload
      assert_equal confirmation_reminders_to_send, fu.confirmation_reminders_to_send
      assert_equal confirmation_reminders_sent, ActionMailer::Base.deliveries.length
    end

    # prepare object to delete it after x days
    delete_after_days = reminder_days.last + Mixins::AccountReminder.confirmation_period(FrontendUser)
    fu.created_at = (now - ((delete_after_days + 99).days))
    assert fu.save
    
    # delete not confirmed users after some days without to send an email
    Mixins::AccountReminder.remember_to_confirm({:show_messages => false})
    fu = FrontendUser.find_by_id(fu.id)
    assert fu.nil?
    
    assert_equal confirmation_reminders_sent, ActionMailer::Base.deliveries.length
    assert_equal 0, confirmation_reminders_to_send
  ensure
    FrontendUser.record_timestamps = true
  end

  def test_anonymize_user
    FrontendUser.delete_all
    
    fu = FrontendUser.create(valid_attributes({:new_email => 'janet@jackson.com'}))
    assert fu.valid?
    assert_equal 'waiting', fu.state
    
    assert fu.confirm!
    assert_equal 'confirmed', fu.state
    
    assert fu.anonymize!
    
    assert fu.anonymized?
    assert fu.login.blank?
    assert fu.email.blank?
    assert fu.new_email.blank?
    assert fu.salutation.blank?
    assert fu.first_name.blank?
    assert fu.name.blank?
    assert fu.birthday.blank?

    assert fu.valid?
  end

  def test_change_email
    FrontendUser.delete_all

    fu = FrontendUser.create(valid_attributes)
    assert fu.valid?
    assert fu.confirm!
    assert_equal 'confirmed', fu.state

    ActionMailer::Base.deliveries = []
    fu.new_email = fu.email
    assert fu.save
    assert fu.confirmed?
    assert ActionMailer::Base.deliveries.empty?

    fu.new_email = 'janet'
    assert !fu.save
    assert fu.confirmed?
    assert ActionMailer::Base.deliveries.empty?

    fu.new_email = 'janet@jackson.com'
    assert fu.save
    assert fu.changing_email?
    check_sending_email_confirmation_code(fu)

    assert fu.confirm!
    assert fu.confirmed?
    assert fu.new_email_before_type_cast.blank?
    assert fu.read_attribute(:new_email).blank?
    assert_equal 'janet@jackson.com', fu.email
    assert_equal fu.email, fu.new_email
  end
  
  def test_reset_new_email!
    FrontendUser.delete_all

    frontend_user = FrontendUser.create(valid_attributes)
    assert frontend_user.valid?
    assert frontend_user.confirm!
    assert_equal 'confirmed', frontend_user.state
    
    ActionMailer::Base.deliveries = []
    frontend_user.new_email = 'janet@jackson.com'
    assert frontend_user.save
    assert frontend_user.changing_email?
    check_sending_email_confirmation_code(frontend_user)
    
    assert frontend_user.reset_new_email!
    #assert frontend_user.new_email.blank?
    assert frontend_user.confirmed?
  end

  def test_check_email_domain
    cch = CustomConfigHandler.instance
    blacklisted_email_domains = cch.blacklisted_email_domains
    wrong_email_domain = blacklisted_email_domains.first
    
    fu = FrontendUser.create(valid_attributes({:email => "micheal@#{wrong_email_domain}"}))
    assert fu.invalid?
    assert fu.errors[:email].any?
    if Rails.version >= '3.0.0'
      assert fu.errors[:email].first.include?(wrong_email_domain)
    else
      assert fu.errors[:email].include?(wrong_email_domain)
    end
  end

  def test_create_unknown_user
    attributes = {:name => 'thormoor', :email => 'wick@inger.de'}
    fu = FrontendUser.new(attributes)
    assert_equal 'pending', fu.state
    assert (not fu.valid?)
    assert_equal fu.login, attributes[:email]
    assert (not fu.errors[:login].any?)
    assert (not fu.errors[:email].any?)
    assert (not fu.errors[:name].any?)
    
    fu.unknown
    assert_equal 'unknown', fu.state
    assert fu.valid?
    assert fu.login.blank?
    assert (not fu.errors[:login].any?)
    assert (not fu.errors[:email].any?)
    assert (not fu.errors[:name].any?)
    
    fu.name = ''
    assert (not fu.valid?)
    assert (not fu.errors[:login].any?)
    assert (not fu.errors[:email].any?)
    assert fu.errors[:name].any?
    
    fu.name = attributes[:name]
    
    fu.email = ''
    assert (not fu.valid?)
    assert (not fu.errors[:login].any?)
    assert fu.errors[:email].any?
    assert (not fu.errors[:name].any?)
  end

  def test_do_not_destroy_waiting_user_with_content
    # prepare the test
    FrontendUser.delete_all
    ActionMailer::Base.deliveries = []
    
    now = Time.now
    
    # create a frontend user
    fu = FrontendUser.create(
      valid_attributes({:created_at => now, :updated_at => now})
    )
    assert fu.valid?
    assert_equal 'waiting', fu.state
    
    r = Review.first
    r.frontend_user = fu
    assert r.save
    
    reminder_days = Mixins::AccountReminder.confirmation_reminder_days(FrontendUser)
    delete_after_days = reminder_days.last + Mixins::AccountReminder.confirmation_period(FrontendUser)
    
    fu.created_at = (now - (delete_after_days.days + 1.hour))
    assert fu.save

    # delete not confirmed users after some days without to send an email
    Mixins::AccountReminder.remember_to_confirm #({:show_messages => false})
    
    fu.reload
    
    assert_equal 'not_deletable', fu.state
  end
  
  def test_can_login
    # new record can not login
    fu = FrontendUser.create
    assert fu.pending?
    assert (not fu.can_login?)
    
    # unknown user can not login
    fu = FrontendUser.new(valid_attributes)
    fu.unknown
    assert fu.save
    assert fu.unknown?
    assert (not fu.can_login?)
    
    fu.destroy
    assert fu.frozen?
    
    # waiting user can login
    fu = FrontendUser.create(valid_attributes)
    assert fu.waiting?
    assert fu.can_login?
    
    # confirmed user can login
    assert fu.confirm!
    assert fu.confirmed?
    assert fu.can_login?
    
    # user, who is changing the email, can login
    assert fu.change_email!
    assert fu.changing_email?
    assert fu.can_login?
    
    # blocked user can not login
    assert fu.confirm!
    assert fu.block!
    assert fu.blocked?
    assert (not fu.can_login?)
    
    # anonymized user can not login
    assert fu.anonymize!
    fu.reload
    assert fu.anonymized?
    assert (not fu.can_login?)
    
    fu.destroy
    assert fu.frozen?
    
    # not deleteable user can not login
    fu = FrontendUser.create(valid_attributes)
    assert fu.not_deletable!
    assert fu.not_deletable?
    assert (not fu.can_login?)
  end
  
  def test_confirmation_period
    assert_equal 10, FrontendUser.confirmation_period
  end
  
  def test_block_user_and_lock_all_reviews
    ReviewLocking.delete_all
    ActionMailer::Base.deliveries = []
    assert fu = FrontendUser.find(:first, {:conditions => {:state => 'confirmed'}})
    reviews_total = Review.count
    review_states = Review.all.map{|r| r.state}.sort
    Review.all.each{|r| r.frontend_user = fu; assert r.save}
    
    
    fu.block!
    
    reviews_locked_total = Review.locked.count
    assert_equal reviews_total, reviews_locked_total
    assert_equal ReviewLocking.count, reviews_locked_total
    assert_equal review_states, ReviewLocking.all.map{|rl| rl.state}.sort
    assert_equal 0, ActionMailer::Base.deliveries.length
  end
    
  private

  def valid_attributes(add_attributes={})
    {
      :login => 'mija',
      :first_name => 'Micheal',
      :name => 'Jackson',
      :email => 'micheal@jackson.com',
      :password => 'test-pwpwpw',
      :password_confirmation => 'test-pwpwpw',
      :general_terms_and_conditions => true
    }.merge(add_attributes)
  end

  def valid_attributes_2(add_attributes={})
    {
      :login => 'jaja',
      :first_name => 'Janet',
      :name => 'Jackson',
      :email => 'janet@jackson.com',
      :password => 'test-pwpwpw',
      :password_confirmation => 'test-pwpwpw',
      :general_terms_and_conditions => true
    }.merge(add_attributes)
  end

  def check_sending_confirmation_email(user, deliveries)
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal deliveries, ActionMailer::Base.deliveries.length
    tmail = ActionMailer::Base.deliveries.last
    assert tmail.to.include?(user.email)
    assert_equal 'text/plain', tmail.content_type
    assert_equal 'UTF-8', tmail.charset
    assert_equal I18n.translate('mailers.frontend.frontend_user_mailer.confirmation_code.subject'),
      tmail.subject
  end

  def check_sending_email_confirmation_code(user)
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal 1, ActionMailer::Base.deliveries.length
    tmail = ActionMailer::Base.deliveries.first
    assert tmail.to.include?(user.new_email)
    assert_equal 'text/plain', tmail.content_type
    assert_equal 'UTF-8', tmail.charset
    assert_equal I18n.translate('mailers.frontend.frontend_user_mailer.email_confirmation_code.subject'),
      tmail.subject
  end

  def check_sending_a_reminder_email(user, forwarded_confirmation_emails)
    assert_equal forwarded_confirmation_emails, ActionMailer::Base.deliveries.length
    tmail = ActionMailer::Base.deliveries[forwarded_confirmation_emails - 1]
    assert tmail.to.include?(user.email)
    assert_equal 'text/plain', tmail.content_type
    assert_equal 'UTF-8', tmail.charset
    assert_equal I18n.translate('mailers.frontend.frontend_user_mailer.confirmation_reminder.subject', {
        :number => forwarded_confirmation_emails - 1
      }), tmail.subject
  end
end
