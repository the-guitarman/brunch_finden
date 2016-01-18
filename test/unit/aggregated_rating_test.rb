#encoding: utf-8
require 'test_helper'

class AggregatedRatingTest < ActiveSupport::TestCase
  fixtures :locations

  # process before each test method
  def setup
    @l1 = Location.first
    @rq1 = ReviewQuestion.first
    @rq2 = ReviewQuestion.last
  end

  # process before each test method
  def teardown

  end

  def test_create
    AggregatedRating.delete_all

    test_ac_1 = AggregatedRating.create
    assert (not test_ac_1.valid?)
    assert test_ac_1.errors[:destination].any?
    assert (not test_ac_1.errors[:destination_id].any?)
    assert test_ac_1.errors[:user_count].any?
    assert (not test_ac_1.errors[:value].any?)
    assert_equal 0.0, test_ac_1.value

    assert_equal 0, AggregatedRating.count

    ar_1 = AggregatedRating.create(valid_attributes)
    assert ar_1.valid?
    assert (not ar_1.errors[:destination].any?)
    assert (not ar_1.errors[:destination_id].any?)
    assert_kind_of Location, ar_1.destination
    assert (not ar_1.errors[:user_count].any?)
    assert (not ar_1.errors[:value].any?)
    assert_equal 0.2, ar_1.value

    assert_equal 1, AggregatedRating.count

    test_ar_2 = AggregatedRating.create(valid_attributes)
    assert (not test_ar_2.valid?)
    assert (not test_ar_2.errors[:destination].any?)
    assert test_ar_2.errors[:destination_id].any?
    assert_kind_of Location, test_ar_2.destination
    assert (not test_ar_2.errors[:user_count].any?)
    assert (not test_ar_2.errors[:value].any?)
    assert_equal 0.2, test_ar_2.value

    assert_equal 1, AggregatedRating.count

    ar_2 = AggregatedRating.create(valid_attributes({:review_question => @rq2}))
    assert ar_2.valid?
    assert (not ar_2.errors[:destination].any?)
    assert (not ar_2.errors[:destination_id].any?)
    assert_kind_of Location, ar_2.destination
    assert (not ar_2.errors[:user_count].any?)
    assert (not ar_2.errors[:value].any?)
    assert_equal 0.2, ar_2.value

    assert_equal 2, AggregatedRating.count
  end

  def test_assosiations
    ac = AggregatedRating.first
    assert_respond_to ac, :review_question
    assert_respond_to ac, :destination

    ac.review_question.is_a?(ReviewQuestion)
    ac.destination.is_a?(Location)
  end

  def test_update

  end

  def test_destroy
    ar = AggregatedRating.first

    ar.destroy
    assert ar.frozen?
  end

  private

  def valid_attributes(add_attributes={})
    {
      :review_question => @rq1,
      :destination  => @l1,
      :user_count   => 1,
      :value        => 0.2
    }.merge(add_attributes)
  end
end
