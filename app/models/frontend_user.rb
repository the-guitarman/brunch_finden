class FrontendUser < ActiveRecord::Base
  attr_accessor :is_reseting_password
  
  include Mixins::AccountReminder
  
  include Mixins::EmailDomainChecker
  acts_as_email_domain_checker(:email, :new_email)
  
  include Mixins::BadWordChecker
  #bad_word_check_for(:name, :email)
  bad_word_check_for(:login, :first_name, :name, :email, :new_email, {
    :unless => Proc.new{|fu| fu.state == 'anonymized' or fu.is_reseting_password}
  })
  
  include Mixins::Salutation
  include Mixins::ActsAsRater
  include Mixins::FrontendUserScorer
  

  # THE STATE MACHINE ----------------------------------------------------------
  INITIAL_STATE = :pending
  ANONYMIZED_STATE = :anonymized
  UNKNOWN_STATE = :unknown
  STATES = {
    INITIAL_STATE    => 'new user accounts initial state',
    :waiting         => 'new user account is waiting for confirmation',
    :confirmed       => 'user confirmed the registration',
    :changing_email  => 'user changed its email address',
    :blocked         => 'user can not log in',
    ANONYMIZED_STATE => 'personal user data deleted',
    UNKNOWN_STATE    => 'user has login and email only',
    :not_deletable   => 'can not delete user, because he has some content'
  }
  
  GENDERS = {
    :mr => 'male', 
    :ms => 'female', 
    nil => 'undefined'
  }
  DEFAULT_GENDER = 'undefined'

  include AASM
  attr_protected :state
  aasm :column => :state do
    STATES.keys.each do |key|
      state key, (key == INITIAL_STATE ? {:initial => true} : {})
    end
    
    event :set_init_state do
      transitions :to => :pending, :from => :unknown
    end
    # creates instance methods wait_for_confirmation, wait_for_confirmation! and
    # waiting? for later usage
    event :wait_for_confirmation do
      transitions :to => :waiting, :from => :pending
    end
    # creates instance methods unknown, unknown! and unknown? for later usage
    event :unknown, :before => :empty_login_aasm_callback do
      transitions :to => :unknown, :from => :pending
    end
    # creates instance methods not_deletable, not_deletable! and not_deletable? for later usage
    event :not_deletable do
      transitions :to => :not_deletable, :from => :waiting
    end
    # creates instance methods confirm, confirm! and confirmed? for later usage
    event :confirm, :before => :prepare_confirmation_aasm_callback do
      transitions :to => :confirmed, :from => :waiting
      transitions :to => :confirmed, :from => :blocked
      transitions :to => :confirmed, :from => :changing_email
      transitions :to => :confirmed, :from => :not_deletable
    end
    # creates instance methods change_email, change_email! and changing_email? for later usage
    event :change_email do
      transitions :to => :changing_email, :from => :confirmed
      transitions :to => :changing_email, :from => :changing_email
    end
    # creates instance methods block, block! and blocked? for later usage
    event :block do
      transitions :to => :blocked, :from => :confirmed
      transitions :to => :blocked, :from => :waiting
      transitions :to => :blocked, :from => :not_deletable
    end
    # creates instance methods anonymize, anonymize! and anonymized? for later usage
    event :anonymize do
      transitions :to => :anonymized, :from => :confirmed
      transitions :to => :anonymized, :from => :blocked
      transitions :to => :anonymized, :from => :not_deletable
    end
  end


  # AUTHLOGIC ------------------------------------------------------------------

  anonymized_proc = Proc.new do |user|
    user.anonymized?
  end
  anonymized_or_unknown_proc = Proc.new do |user|
    anonymized_proc.call(user) or user.unknown?
  end

  acts_as_authentic do |config|
    config.login_field = :login
    config.logged_in_timeout = 120.minutes # default is 10.minutes
    #config.transition_from_crypto_providers = [Authlogic::CryptoProviders::MD5]

    config.merge_validates_format_of_email_field_options({
      :if => :email?,
      :unless => anonymized_proc
    })
    config.merge_validates_length_of_email_field_options({
      :if => :email?,
      :unless => anonymized_proc
    })
    config.merge_validates_uniqueness_of_email_field_options({
      :if => :email?,
      :unless => anonymized_proc
    })
    
    config.validate_login_field({
      :unless => anonymized_or_unknown_proc
    })
    config.merge_validates_format_of_login_field_options({
      #:with => /^[\w\d][\w\d\-@]+[\w\d]$/,
      #:message => I18n.t('error_messages.login_invalid',
      #  :default => "should use only letters, numbers, and -@ please."),
      :if => :login?,
      :unless => anonymized_or_unknown_proc
    })
    config.merge_validates_length_of_login_field_options({
      :if => :login?,
      :unless => anonymized_or_unknown_proc
    })
    config.merge_validates_uniqueness_of_login_field_options({
      :if => :login?,
      :unless => anonymized_or_unknown_proc
    })

    config.merge_validates_length_of_password_field_options({
      :unless => anonymized_or_unknown_proc
    })
    config.merge_validates_confirmation_of_password_field_options({
      :unless => anonymized_or_unknown_proc
    })
    config.merge_validates_length_of_password_confirmation_field_options({
      :unless => anonymized_or_unknown_proc
    })
  end
  
  include Mixins::PerishableTokenKeeper
  
  validates_format_of :new_email, validates_format_of_email_field_options.merge({
      :unless => anonymized_proc})
  validates_length_of :new_email, validates_length_of_email_field_options.merge({
      :if => :new_email?,
      :unless => anonymized_proc})
  validates_uniqueness_of :new_email, validates_uniqueness_of_email_field_options.merge({
      :if => :new_email?,
      :unless => anonymized_proc})

  # ASSOCIATIONS ---------------------------------------------------------------
  
  has_many :locations
  has_many :reviews

  named_scope :showable, :conditions => ['state = ? OR state = ?', :confirmed, :changing_email]
  named_scope :known, :conditions => ['state <> ?', ANONYMIZED_STATE]
  named_scope :short, :select => ("frontend_users.id, frontend_users.login, frontend_users.state, frontend_users.gender, frontend_users.name, frontend_users.first_name, frontend_users.score")

  # VALIDATIONS ----------------------------------------------------------------

  before_validation :set_login, 
    :unless => :unknown?
  
  validates_presence_of :login, :unless => anonymized_or_unknown_proc 
  validates_presence_of :email, :unless => anonymized_proc
  validates_presence_of :first_name, :name,
    :unless => Proc.new{|user|
      now_waiting = false
      now_confirmed = false
      block_user = false
      if user.changes.key?('state')
        now_waiting = (
          (user.changes['state'][0] == 'pending' or user.changes['state'][0] == 'unknown') and 
          user.changes['state'][1] == 'waiting'
        )
        now_confirmed = user.changes['state'][0] == 'waiting' and user.changes['state'][1] == 'confirmed'
        block_user = (user.changes['state'][1] == 'blocked')
      end
      user.is_reseting_password or block_user or
      anonymized_or_unknown_proc.call(user) or 
      user.pending? or now_waiting or now_confirmed 
    },
    :on => :update
  validates_presence_of :name, :if => :unknown?
  validates_inclusion_of :gender, :in => GENDERS.values
  validate :check_new_email_uniqueness
  validates_acceptance_of :general_terms_and_conditions, 
    :accept    => true,
    :allow_nil => false,
    :unless    => :unknown?

  # CALLBACKS ------------------------------------------------------------------
  
  before_destroy :before_destroy_handler
  after_update :send_email_changed_email, :lock_content_if_blocked
  after_save :anonymize_if_wanted
  
  after_initialize :set_is_reseting_password

  # INSTANCE METHODS -----------------------------------------------------------

  def user_showable?
    self.state == 'changing_email' or self.state == 'confirmed'
  end

  def can_login?
    return ((not self.new_record?) and (self.waiting? or self.confirmed? or self.changing_email?))
  end

  def new_email
    if self[:new_email].blank?
      read_attribute(:email)
    else
      read_attribute(:new_email)
    end
  end

  def new_email=(value)
    if (self.confirmed? or self.changing_email?) and self.email != value
      write_attribute(:new_email, value)
      if value.blank? == false and self.valid?
        self.change_email
      end
    else
      write_attribute(:new_email, '')
    end
  end
  
  def reset_new_email!
    if self.changing_email?
      self.reset_perishable_token
      self.state = 'confirmed'
      write_attribute(:new_email, '')
      return self.save
    else
      return false
    end
  end

  # CLASS METHODS --------------------------------------------------------------
  
  def self.find_or_initialize_by_email(attributes = {})
    frontend_user = new
    if attributes.is_a?(Hash)
      if email = attributes[:email] || attributes['email']
        unless frontend_user = known.find(:first, :conditions => {:email => email})
          frontend_user = new(attributes)
        end
      end
    end
    return frontend_user
  end

  
  def self.find_by_username_or_email(login_or_email)
    find_by_login(login_or_email) || find_by_email(login_or_email)
  end

  # PRIVATE INSTANCE METHODS ---------------------------------------------------
  
  private

  def anonymize_record
    @anonymize_record = true

    # anonymize user
    password = Authlogic::Random.hex_token
    self.update_attributes({
      :login => '',
      :email => '',
      :new_email => '',
      
      :salutation => '',
      :first_name => '',
      :name => '',
      :birthday => nil,
      
      :password => password,
      :password_confirmation => password,
      
      :active => 0
    })
  end
  
  def before_destroy_handler
    domain_name = CustomConfigHandler.instance.frontend_config['DOMAIN']['NAME'].downcase
    new_fu = self.class.find_by_email("info@#{domain_name}")
    self.locations.find_each({:batch_size => ::GLOBAL_CONFIG[:find_each_batch_size]}) do |l|
      l.frontend_user = new_fu
      l.save
    end
  end

  def send_email_changed_email
    changes = self.changes
    if changes.include?('new_email') and changes.include?('state')
      if changes['new_email'][0].blank? and
         not changes['new_email'][1].blank? and
         changes['state'][0] != 'changing_email'
         changes['state'][1] == 'changing_email'
        if Rails.version >= '3.0.0'
          Mailers::Frontend::FrontendUserMailer.email_confirmation_code(self).deliver
        else
          Mailers::Frontend::FrontendUserMailer.deliver_email_confirmation_code(self)
        end
      end
    end
  end
  
  def lock_content_if_blocked
    if self.state_changed? and self.blocked?
      self.reviews.each do |r|
        r.lock!("Author blocked at #{DateTime.now.to_s(:db)}!")
      end
    end 
  end

  def anonymize_if_wanted
    changes = self.changes
    if changes.include?('state')
      if (changes['state'][1] == 'anonymized' and
         changes['state'][0] != 'anonymized') or
         (self.state == 'anonymized' and self.active != 0)
        anonymize_record unless @anonymize_record
      else
        @anonymize_record = false
      end
    end
  end

  def check_new_email_uniqueness
    unless self.state == 'anonymized' or self.is_reseting_password
      return true if self[:new_email].blank?
      co = FrontendUser.count(:all, :conditions => {:email => self[:new_email]})
      return true if co < 1
      self.errors.add(:new_email, :taken)
      return false
    end
  end
  
  def set_login
    if self.login.blank?
      self.login = self.email
    end
  end
  
  def empty_login_aasm_callback
    self.login = nil
  end
    
  def prepare_confirmation_aasm_callback
    self.reset_perishable_token
    self.active = true unless self.active == true
    self.confirmed_at = DateTime.now unless self.confirmed_at?
    self.confirmation_reminders_to_send = 0
    if self.changing_email?
      self.email = self.new_email
    end
    write_attribute(:new_email, '')
  end
  
  def set_is_reseting_password
    @is_reseting_password = false
  end
end