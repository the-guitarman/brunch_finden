class CouponCategory < ActiveRecord::Base
  include Mixins::RewriteSuggestion
  acts_as_rewrite_suggestionable(
    :generate_rewrite_from => :name
  )

  #has_and_belongs_to_many :coupons, :join_table => :coupons_in_categories
  has_many :coupons_in_categories, :class_name => 'CouponsInCategory', :dependent => :destroy
  has_many :coupons, :through => :coupons_in_categories
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_numericality_of :number_of_coupons, :greater_than_or_equal_to => 0
  
  named_scope :showable, :conditions => 'number_of_coupons > 0'
  
  def update_statistics
    self.number_of_coupons = self.coupons.showable.count
    self.save
  end
  
  def self.update_statistics
    CouponCategory.find_each do |cc|
      cc.update_statistics
    end
  end
end