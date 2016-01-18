#encoding: utf-8
require 'test_helper'

require 'unit/helper/cache_test_helper'
require 'unit/helper/coupon_category_cache_test_helper'
require 'unit/helper/coupon_cache_test_helper'

class CouponTest < ActiveSupport::TestCase
  include CouponCategoryCacheTestHelper
  include CouponCacheTestHelper
  
  should have_many(:coupons_in_categories).dependent(:destroy)
  should have_many(:coupon_categories)
  should have_many(:coupon_matches).dependent(:destroy)
  should belong_to :coupon_merchant
  should belong_to(:customer)
  
  #validates_uniqueness_of :coupon_id, :scope => :customer_id
  context 'test uniqueness of coupon_id scoped to customer id' do
    subject {Coupon.find(1)}
    should validate_uniqueness_of(:coupon_id).scoped_to(:customer_id) #.with_foreign_key()
  end
  
  should validate_presence_of(:coupon_id) #.with_message(/is required/)
  should validate_presence_of(:name) #.with_message(/is required/)
  should validate_presence_of(:valid_from) #.with_message(/is required/)
  should validate_presence_of(:valid_to) #.with_message(/is required/)
  should validate_presence_of(:merchant_id) #.with_message(/is required/)
  should validate_presence_of(:url) #.with_message(/is required/)
  
  # process before each test method
  def setup
    
  end

  # process before each test method
  def teardown

  end

  def test_01_create
    Coupon.delete_all
    
    # test presence of attributes
    c_test_1 = Coupon.create
    assert !c_test_1.valid?
    assert c_test_1.errors.invalid?(:coupon_id)
    assert c_test_1.errors.invalid?(:name)
    assert c_test_1.errors.invalid?(:valid_from)
    assert c_test_1.errors.invalid?(:valid_to)
    assert c_test_1.errors.invalid?(:merchant_id)
    assert c_test_1.errors.invalid?(:url)
    
    c = Coupon.create(valid_attributes)
    assert c.valid?
    assert !c.errors.invalid?(:coupon_id)
    assert !c.errors.invalid?(:name)
    assert !c.errors.invalid?(:valid_from)
    assert !c.errors.invalid?(:valid_to)
    assert !c.errors.invalid?(:merchant_id)
    assert !c.errors.invalid?(:url)
    
    # test uniqueness of attributes
    c_test_2 = Coupon.create(valid_attributes)
    assert !c_test_2.valid?
    assert c_test_2.errors.invalid?(:coupon_id)
    assert !c_test_2.errors.invalid?(:name)
    assert !c_test_2.errors.invalid?(:valid_from)
    assert !c_test_2.errors.invalid?(:valid_to)
    assert !c_test_2.errors.invalid?(:merchant_id)
    assert !c_test_2.errors.invalid?(:url)
  end

  def test_02_update
    c = Coupon.first
    
    #create_cache_files(c)
    
    c.name += 'new'
    assert c.save
    
    check_cache_files_do_not_exist(c)
  end

  def test_03_model_associations_constants_included_modules
    c = Coupon.first
    
    assert_respond_to c, :coupon_categories
    assert_respond_to c, :customer
    
    assert Coupon.included_modules.include?(Mixins::ActsAsClickoutable)
    Coupon.clickoutable_url_attributes.include?(:url)
    
    assert Coupon.included_modules.include?(Mixins::TextCleaner)
    if Rails.version < '3.0.0'
      assert Coupon.instance_methods.include?('clean_text_in_name')
      assert Coupon.instance_methods.include?('clean_text_in_hint')
    else
      assert Coupon.instance_methods.include?(:clean_text_in_name)
      assert Coupon.instance_methods.include?(:clean_text_in_hint)
    end
  end

  def test_04_destroy
    c = Coupon.first
    c.destroy
    assert c.frozen?
  end
  
  def test_05_text_cleaner
    Coupon.delete_all
    
    coupon = Coupon.new(valid_attributes)
    
    assert_equal '<strong>20,- € Gutschein</strong> für Neukunden', coupon.name
    assert_equal '<b>Mindestbestellwert 40,- €.</b> Nur für Neukunden gültig und nicht kombinierbar mit anderen Aktionen. Code im 3. Bestellschritt angeben.', 
      coupon.hint
    
    assert coupon.save
    
    assert_equal '20,- € Gutschein  für Neukunden', coupon.name
    assert_equal 'Mindestbestellwert 40,- €.  Nur für Neukunden gültig und nicht kombinierbar mit anderen Aktionen. Code im 3. Bestellschritt angeben.', 
      coupon.hint
  end

  private

  def valid_attributes(add_attributes={})
    {
      :customer_id       => 4,
      :code              => '61624',
      :coupon_id         => 1366,
      :favourite         => false,
      :hint              => '<b>Mindestbestellwert 40,- €.</b> Nur für Neukunden gültig und nicht kombinierbar mit anderen Aktionen. Code im 3. Bestellschritt angeben.',
      :kind              => 0,
      :merchant_id       => 1,
      :name              => '<strong>20,- € Gutschein</strong> für Neukunden',
      :priority          => 40,
      :url               => 'http://zumanbieter.de/?mid=779000&id=1366',
      :valid_from        => Time.now.beginning_of_month,
      :valid_to          => Time.now.end_of_month
    }.merge(add_attributes)
  end

  def create_cache_files(coupon)
    create_coupon_cache_files(coupon)
    coupon.coupon_categories.each do |coupon_category|
      create_coupon_category_cache_files(coupon_category)
    end
    #create_coupon_categories_cache_file
  end

  def check_cache_files_do_not_exist(coupon)
    check_coupon_cache_files_do_not_exist(coupon)
    coupon.coupon_categories.each do |coupon_category|
      check_coupon_category_cache_files_do_not_exist(coupon_category)
    end
    #check_coupon_category_cache_file_does_not_exist
  end
end
