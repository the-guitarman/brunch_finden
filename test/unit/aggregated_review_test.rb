#encoding: utf-8
require 'test_helper'

class AggregatedReviewTest < ActiveSupport::TestCase
  fixtures :locations

  # process before each test method
  def setup
    @l1 = Location.first
  end

  # process before each test method
  def teardown

  end

  def test_create
    AggregatedReview.delete_all
    
    test_ac_1 = AggregatedReview.create
    assert (not test_ac_1.valid?)
    assert test_ac_1.errors[:destination].any?
    assert test_ac_1.errors[:user_count].any?
    assert (not test_ac_1.errors[:value].any?)
    assert_equal 0.0, test_ac_1.value

    assert_equal 0, AggregatedReview.count

    ac_1 = AggregatedReview.create(valid_attributes)
    assert ac_1.valid?
    assert (not ac_1.errors[:destination].any?)
    assert_kind_of Location, ac_1.destination
    assert (not ac_1.errors[:user_count].any?)
    assert (not ac_1.errors[:value].any?)
    assert_equal 0.2, ac_1.value
  end

  def test_assosiations
    ac = AggregatedReview.first
    assert_respond_to ac, :destination
    
    assert AggregatedReview.included_modules.include?(Mixins::PolymorphicFinder)
  end

  def test_update
    
  end

  def test_destroy
    ac = AggregatedReview.first

    ac.destroy
    assert ac.frozen?
  end
  
  def test_self_users_per_value
    # users per value hash should have values for full stars (0,1,2,3,4,5) only
    upv = AggregatedReview.users_per_value
    assert upv.is_a?(Hash)
    expected_hash = {0.0=>0, 0.2=>0, 0.4=>0, 0.6=>0, 0.8=>0, 1.0=>0}
    assert_equal expected_hash, upv
  end

  private

  def valid_attributes(add_attributes={})
    {
      :destination  => @l1,
      :user_count   => 1,
      :value        => 0.2
    }.merge(add_attributes)
  end
end
