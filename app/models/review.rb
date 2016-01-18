class Review < ActiveRecord::Base
  include Mixins::UserGeneratedContent
  
  include Mixins::PolymorphicFinder
  polymorphic_finder_for :destination
  
  include Mixins::SecureCode
  secure_code_for :confirmation_code
  
  include Mixins::ReviewCompleteness  
  
  include Mixins::TextCleaner
  clean_text_in(:text, {
    :action_formatter => {
      :replace_newlines => "\n", 
      :format_headlines => 'remove', 
      :ascii_art        => 'remove', 
      :html_optimize    => 'all', 
      :html_filter      => 'all' # 'br,h2,h3,h4,strong,em,span,ol,ul,li,p'
    }
  })

  include Mixins::CentInteger
  cover_as_cent_integer :value
  cover_as_milli_integer :aggregated_rating
  
  VALUE_BETWEEN = [0.0, 1.0]
  
  VALUES = {
    0.0 => 0,
    0.05 => 0.5,
    0.1 => 0.5,
    0.15 => 1,
    0.2 => 1,
    0.25 => 1.5,
    0.3 => 1.5,
    0.35 => 2,
    0.4 => 2,
    0.45 => 2.5,
    0.5 => 2.5,
    0.55 => 3,
    0.6 => 3,
    0.65 => 3.5,
    0.7 => 3.5,
    0.75 => 4,
    0.8 => 4,
    0.85 => 4.5,
    0.9 => 4.5,
    0.95 => 5,
    1.0 => 5
  }

  STATES = {
    :unpublished => 0, 
    :published   => 1, 
    :locked      => 2 
  }
  
  include Mixins::ActsAsRaterScorer
  acts_as_rater_scorer :frontend_user, {
    :state => [STATES[:published], 100],
    :helpful_yes => [:inc, 10],
    :helpful_no  => [:dec, 10],
    :after_destroy => true
  }
  
  DELETION_LOG_FILE = "#{Rails.root}/log/review_deletions.log"
  
  belongs_to :destination, :polymorphic => true
  belongs_to :frontend_user
  has_one  :review_locking, :dependent => :destroy
  has_many :ratings, :dependent => :destroy
  
  validates_presence_of :destination
  # on create, a new frontend user has no id, but the 
  # frontend user associated should be present and ...  
  validates_presence_of :frontend_user, :on => :create
  # ... valid, if it's a new frontend user
  validates_associated :frontend_user, :on => :create,
    :if => Proc.new{|r| r.frontend_user and r.frontend_user.new_record?}
  # on update, there have to be a frontend_user_id, 
  # because the frontend user should exist
  validates_presence_of :frontend_user_id, :on => :update
  validates_uniqueness_of :frontend_user_id,
    :scope => [:destination_id, :destination_type],
    :on => :create
  validates_presence_of :value
  validates_numericality_of :value,
    :greater_than_or_equal_to => VALUE_BETWEEN.first,
    :less_than_or_equal_to    => VALUE_BETWEEN.last,
    :if => :value?
  validates_associated :review_locking
  validates_presence_of :review_locking,
    :if => :locked?
  validates_acceptance_of :general_terms_and_conditions, 
    :accept    => true,
    :allow_nil => false
  
  before_save :preserve_changes #, :calculate_value
  before_update :check_states
  after_save :aggregate_reviews, :destroy_review_locking_if_new_state_is_not_locked
  after_destroy :aggregate_reviews, :log_deleted_comments, :touch_associated
  
  named_scope :showable, {:conditions => {:state => STATES[:published]}}
  named_scope :unpublished, {:conditions => {:state => STATES[:unpublished]}}
  named_scope :locked, {:conditions => {:state => STATES[:locked]}}
  
  def review_template
    ret = nil
    ret = self.destination.review_template if self.destination
    return ret
  end
  
  def dublicates
    ret = []
    if dest = self.destination and self.frontend_user_id?
      ret = self.class.where({
        :frontend_user_id => self.frontend_user_id,
        :destination_type => self.destination_type
      })
      if dest.is_a?(Product)
        ret = ret.where("destination_id IN (#{dest.group_ids.join(',')})")
      else
        ret = ret.where(["destination_id = ?", self.destination_id])
      end
      ret = ret.all
    end
    return ret
  end
  
  def other_from_this_author
    ret = []
    if self.frontend_user_id?
      ret = self.class.where({:frontend_user_id => self.frontend_user_id})
      ret = ret.where(["id <> ?", self.id]) unless self.new_record?
      ret = ret.all
    end
    return ret
  end
  
  def review_rating
    return nil unless self.aggregated_rating
    return 1.0 if self.aggregated_rating >= 0.9
    return 0.8 if self.aggregated_rating >= 0.7
    return 0.6 if self.aggregated_rating >= 0.5
    return 0.4 if self.aggregated_rating >= 0.3
    return 0.2 if self.aggregated_rating >= 0.1
    return 0.0
  end

  def human_readable_state
    irs =  STATES.invert
    irs[self.state].to_s
  end

  def locked?
    self.state == STATES[:locked]
  end
  
  def published?
    self.state == STATES[:published]
  end
  
  def unpublished?
    self.state == STATES[:unpublished]
  end

  def publish!
    ret = false
    unless self.published?
      self.state = STATES[:published]
      self.published_at = DateTime.now unless self.published_at?
      self.reset_secure_code_fields if self.respond_to?(:reset_secure_code_fields)
      if ret = self.save
        touch_associated
      end
    end
    return ret
  end
  
  def lock(reason = nil)
    ret = true
    current_state = self.state
    self.state = STATES[:locked]
    unless self.review_locking
      if not reason.blank? and reason.is_a?(String)
        self.review_locking = ReviewLocking.new({:state => current_state, :reason => reason})
      else
        self.errors.add(:review_locking, :reason_required)
        ret = false
      end
    end
    return ret
  end
  
  def lock!(reason = nil)
    if lock(reason)
      return self.save
    else
      return false
    end
  end
  
  def rating_of(frontend_user)
    return nil if frontend_user.blank? or frontend_user.new_record?
    return self.review_ratings.where({:frontend_user_id => frontend_user.id}).first
  end
  
  def rated_by?(frontend_user)
    return !self.rating_of(frontend_user).blank?
  end
  
  def rating_published?(frontend_user)
    rr = self.rating_of(frontend_user)
    return (!rr.blank? and rr.published?)
  end
  
  def written_by?(frontend_user)
    return self.frontend_user == frontend_user
  end
  
#  def destroy_with_reason(reason = nil)
#    ret = false
#    if not reason.blank? and reason.is_a?(String)
#      self.destroy
#      if ret = self.frozen?
#        if self.state == STATES[:published] and send_email? and not reason.blank?
#          if Rails.version >= '3.0.0'
#            Mailers::Frontend::ReviewMailer.review_destroyed(self, reason).deliver
#          else
#            Mailers::Frontend::ReviewMailer.deliver_review_destroyed(self, reason)
#          end
#        end
#      end
#    else
#      self.errors.add(:base, :destroy)
#    end
#    return ret
#  end

  def calculate_aggregated_rating
    rr = ratings
    if rr.count > 0
      sum = 0
      rr.each do |review_rating|
        sum += review_rating.value
      end
      
      #FIXME: what is a better way to calculate correct values ?
      sum = BigDecimal.new(sum.to_s)
      self.aggregated_rating = (sum/rr.count).to_f
    else
      self.aggregated_rating = nil
    end
    self.save if self.changed?
  end

  # TODO: move it to frontend_user
  def send_email? 
    frontend_user_states_blacklist = [:blocked, :anonymized, :not_deletable]
    if frontend_user_states_blacklist.include?(self.frontend_user.state.to_sym)
      return false
    else
      return true
    end
  end

  def stars
    ret = nil
    if self.value?
      ret = Review.stars(self.value)
    end
    return ret
  end

  def stars?
    return (not self.stars.nil?)
  end
  
  def self.decimal_stars(value, precision = 1)
#    ret = 0
#    nv = normalized_value(value)
#    ret = value * stars(value) / nv if nv > 0
#    ret = ret.to_i if ret == ret.to_i
#    return ret
    ret = (value.to_f * VALUES.values.max) # / VALUES.keys.max
    ret = sprintf("%#.#{precision}f", ret.to_s).to_f
    if ret > VALUES.values.max
      ret = VALUES.values.max
    elsif ret == ret.to_i
      ret = ret.to_i
    end
    return ret
  end

  #def self.decimal_stars(value, precision = 1, force_precision = false)
  #  ret = 0
  #  nv = normalized_value(value)
  #  ret = value * stars(value) / nv if nv > 0
  #  if not force_precision and (precision == 0 or ret == ret.to_i)
  #    ret = ret.to_i
  #  else
  #    ret = sprintf("%.#{precision}f", ret).to_f
  #  end
  #  return ret
  #end
  
  def self.normalized_value(value)
    VALUES.sort.reverse_each do |el|
      return el.first if value.to_f >= el.first
    end
    return 0.0
  end
  
  def self.stars(value)
    VALUES[normalized_value(value)]
  end
  
  def self.star_values(half_stars = false)
    unless half_stars
      proc = Proc.new{|k,v| k_10 = k * 10; (k_10 - k_10.to_i) == 0 and v.is_a?(Integer)}
    else
      proc = Proc.new{|k,v| k_10 = k * 10; (k_10 - k_10.to_i) == 0}
    end
    Review::VALUES.find_all{|k,v| proc.call(k,v)}.sort
  end
  
  private
  
  def check_states
    ret = true
    if @changes.include?('state')
      if @changes['state'][0] != STATES[:unpublished] and
         @changes['state'][1] == STATES[:unpublished]
        self.errors.add(:state, :invalid)
        ret = false
      end
    end
    return ret
  end
  
  def destroy_review_locking_if_new_state_is_not_locked
    if @changes.include?('state')
      if @changes['state'][0] == STATES[:locked] and 
         @changes['state'][1] != STATES[:locked]
        self.review_locking.destroy if self.review_locking
      end
    end
  end

  def aggregate_reviews
    AggregatedReview.recalculate(self.destination)
    self.ratings.each do |r|
      r.calculate_aggregations
    end
  end
  
  def calculate_value
    val = 0
    count = 0
    ratings.each do |r|
      val += r.value
      count += 1
    end
    self.value = count > 0 ? val / count : 0
  end
  
  def log_deleted_comments
    msg = "#{I18n.l(Time.now, :format => :log_file)}, " +
      "USER: #{self.frontend_user.id} - #{self.frontend_user.login}, " +
      "ID: #{self.id}, " +
      "TEXT: #{self.text}\n"
    File.open(Review::DELETION_LOG_FILE, 'a') do |f|
      f.write(msg)
    end
  end
  
  def touch_associated
    self.destination.touch
  end
end
