#encoding: utf-8
require 'test_helper'

class CouponMerchantTest < ActiveSupport::TestCase
  should have_many(:coupons).dependent(:destroy)
  
  should validate_presence_of(:merchant_id)
  should validate_presence_of(:name)
  context 'test uniqueness of merchant_id' do
    subject {CouponMerchant.find(1)}
    should validate_uniqueness_of(:merchant_id)
  end
  #validates :number_of_coupons, :numericality => {:greater_than_or_equal_to => 0}

  def test_model_constants_and_included_modules
    assert CouponMerchant.included_modules.include?(Mixins::TextCleaner)
    if Rails.version < '3.0.0'
      assert CouponMerchant.instance_methods.include?('clean_text_in_name')
      assert CouponMerchant.instance_methods.include?('clean_text_in_description')
    else
      assert CouponMerchant.instance_methods.include?(:clean_text_in_name)
      assert CouponMerchant.instance_methods.include?(:clean_text_in_description)
    end
  end
  
  def test_text_cleaner
    CouponMerchant.delete_all
    
    cm = CouponMerchant.new(valid_attributes)
    
    assert_equal '<i>sheego</i>', cm.name
    assert_equal '<i>sheego</i>', cm.description
    
    assert cm.save
    
    assert_equal 'sheego', cm.name
    assert_equal 'sheego', cm.description
  end

  private

  def valid_attributes(add_attributes={})
    {
      :merchant_id => 999,
      :name        => '<i>sheego</i>',
      :logo_url    => 'http://ad.zanox.com/ppv/?15066635C2017095969',
      :description => '<i>sheego</i>'
    }.merge(add_attributes)
  end
end
