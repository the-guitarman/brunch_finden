class Coupon < ActiveRecord::Base
  include Mixins::TextCleaner
  clean_text_in(:name, :hint, {
    :action_formatter => {
      :replace_newlines => "\n", 
      :format_headlines => 'remove', 
      :ascii_art        => 'remove', 
      :html_optimize    => 'all', 
      :html_filter      => 'all'
    }
  })

  include Mixins::ActsAsClickoutable
  acts_as_clickoutable(:url)
  
  include Mixins::HasDeltaGuard
  switch_delta_only_for(:name, :hint, :valid_to)
  
  TYPES = {
    0 => 'rabattcoupons', # discount
    1 => 'gewinnspiele',  # competition
    2 => 'gratiscoupons_produktproben', # gratis
    3 => 'angebot', # offer
  }
  
  TRANSLATIONS = {
    0 => I18n.t('shared.coupons.kind.discount'),
    1 => I18n.t('shared.coupons.kind.competition'),
    2 => I18n.t('shared.coupons.kind.gratis'),
    3 => I18n.t('shared.coupons.kind.offer')
  }
  
  #has_and_belongs_to_many :coupon_categories, :join_table => :coupons_in_categories
  has_many :coupons_in_categories, :class_name => 'CouponsInCategory', :dependent => :destroy
  has_many :coupon_categories, :through => :coupons_in_categories
  
  belongs_to :coupon_merchant, :foreign_key => :merchant_id, :primary_key => :merchant_id
  has_many :coupon_matches, :dependent => :destroy
  belongs_to :customer
  
  validates_uniqueness_of :coupon_id, :scope => :customer_id
  validates_presence_of :coupon_id, :name, :valid_from, :valid_to, :merchant_id, :url
  
  named_scope :showable, :conditions => ["valid_to >= ?", DateTime.now]
  
  define_index do
    indexes name, :prefixes  => true
    indexes coupon_merchant.name, :prefixes  => true
    indexes coupon_categories.name
    indexes hint
    
    has valid_to

    set_property :min_prefix_len => 1
    #set_property :min_infix_len => 3
    set_property :enable_star   => true
    set_property :delta         => true
  end
  
  def only_new_customer=(value)
    if value.blank?
      write_attribute(:only_new_customer, nil)
    elsif value == 'true'
      write_attribute(:only_new_customer, true)
    elsif value == 'false'
      write_attribute(:only_new_customer, false)
    else
      write_attribute(:only_new_customer, value)
    end
  end
  
  def kind=(value)
    write_attribute(:kind, TYPES.index(value))
  end
  
  def kind
    TYPES[read_attribute(:kind)]
  end
  
  def destroy
    self.instance_variable_set(:@coupon_categories_ids, self.coupon_category_ids)
    super
  end
end
