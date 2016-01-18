class Customer < ActiveRecord::Base
  #include Mixins::HasDeltaGuard
  #switch_delta_only_for(:name)
  
  CUSTOMER_TYPES = {
    #:affiliate  => 'Affiliate Network',
    #:agency     => 'Agency',
    #:shop_owner => 'Shop-Owner',
    :coupon_supplier => 'Coupon Supplier'
  }
  STATES = {
    :active   => 1,
    :inactive => 2,
    :deleted  => 3
  }

  # ASSOCIATIONS ---------------------------------------------------------------

  has_many :coupons

  # VALIDATIONS ----------------------------------------------------------------

  validates_presence_of :name
  validates_uniqueness_of :name, :if => :name?
  validates_inclusion_of :customer_type, :in => CUSTOMER_TYPES


  # THINKING SPHINX INDEX ------------------------------------------------------

#  define_index do
#    indexes name, :sortable => true
#    
#    has :id
#    has customer_type
#
#    set_property :min_infix_len => 3
#    set_property :enable_star   => true
#    set_property :delta         => true
#  end

  # CALLBACKS METHODS ----------------------------------------------------------

  

  # PUBLIC INSTANCE METHODS ----------------------------------------------------

  def customer_type
    #CUSTOMER_TYPES.key(self[:customer_type])   # rails3
    CUSTOMER_TYPES.index(self[:customer_type]) # rails2
  end

  def customer_type=(key)
    key = key.to_sym if key.instance_of?(String) and !key.strip.empty?
    self[:customer_type] = CUSTOMER_TYPES[key]
  end
end