#encoding: UTF-8
require 'test_helper'

class RatingTest < ActiveSupport::TestCase
  fixtures :review_questions
  fixtures :locations
  fixtures :frontend_users

  should belong_to :review
  should belong_to :review_question

  should validate_presence_of(:review_question)
  should validate_presence_of(:review)

  # process before each test method
  def setup
    @r1 = Review.first
    @l1 = Location.first
    @l2 = Location.last
    @fu1 = FrontendUser.find(1)
    @fu2 = FrontendUser.last
    @rq1_at_list    = ReviewQuestion.find(1)
    @rq2_at_boolean = ReviewQuestion.find(4)
    @rq3_at_text    = ReviewQuestion.find(5)
  end

  # process before each test method
  def teardown

  end

  def test_create
    Rating.delete_all
    Review.delete_all
    AggregatedRating.delete_all
    AggregatedReview.delete_all

    test_r1 = Rating.create
    assert (not test_r1.valid?)
    assert test_r1.errors[:review_question].any?
    assert test_r1.errors[:review].any?
    assert (not test_r1.errors[:value].any?)
    assert (not test_r1.errors[:text].any?)

    assert_equal 0, AggregatedRating.count

    review = Factory(:review, {:frontend_user => @fu1, :state => Review::STATES[:unpublished], :destination => @l1})
    r1 = Factory(:rating, {:review => review, :value => 0.2})
    assert r1.valid?
    assert (not r1.errors[:review_question].any?)
    assert_kind_of ReviewQuestion, r1.review_question
    assert_kind_of Location, r1.destination
    assert_kind_of FrontendUser, r1.frontend_user
    assert (not r1.errors[:value].any?)
    assert_equal 0.2, r1.value
    assert (not test_r1.errors[:text].any?)
    assert_equal 0, AggregatedRating.count

    review = r1.review
    review.reload
    review.state = Review::STATES[:published]
    assert review.save

    assert_equal 1, AggregatedRating.count

    ar = AggregatedRating.first
    assert_equal @rq1_at_list, ar.review_question
    assert_equal @l1, ar.destination
    assert_equal 0.2, ar.value
    assert_equal 1, ar.user_count

    # create a rating (for location 1 from user 2)
    review = Factory(:review, {:frontend_user => @fu2, :state => Review::STATES[:published], :destination => @l1})
    r2 = Factory(:rating, {:review => review, :value => 1.0})
    assert r2.valid?
    assert_equal 2, Rating.count
    assert_equal 1, AggregatedRating.count

    ar = AggregatedRating.first
    assert_equal @l1, ar.destination
    assert_equal 0.6, ar.value
    assert_equal 2, ar.user_count

    # create a rating (for location 2 from user 2)
    review = Factory(:review, {
      :destination => @l2, :frontend_user => @fu2, 
      :state => Review::STATES[:published],
      :text => 'Nun sind Gummibärchen weder wabbelig noch zäh; 
                sie stehen genau an der Grenze. Auch das macht sie spannend. 
                Gummibärchen sind auf eine aufreizende Art weich. 
                Und da sie weich sind, kann man sie auch ziehen. 
                Ich mache das sehr gerne. Ich sitze im dunklen Kino und ziehe 
                meine Gummibärchen in die Länge, ganz ganz langsam.'
    })
    r2 = Factory(:rating,:review=>review,:value => 0.8)
    assert r2.valid?
    assert_equal 3, Rating.count
    assert_equal 2, AggregatedRating.count

    ar = AggregatedRating.first
    assert_equal @l1, ar.destination
    assert_equal 0.6, ar.value
    assert_equal 2, ar.user_count

    ar = AggregatedRating.last
    assert_equal @l2, ar.destination
    assert_equal 0.8, ar.value
    assert_equal 1, ar.user_count

    # create a boolean review
    r3 = Factory(:rating,:review=>review,:review_question => @rq2_at_boolean,:value=>0.2)
    assert r3.valid?
    assert (not r3.errors[:value].any?)
    assert (not r3.errors[:text].any?)

    # create a text review
    r4 = Factory(:rating,:review_question => @rq3_at_text,:review=>review,:text=>"text")
    assert r4.valid?
    assert (not r4.errors[:value].any?)
    assert (not r4.errors[:text].any?)
    
    # can not create facultative? without value
    attributes = valid_attributes({:review_question => ReviewQuestion.find(3)})
    attributes.delete(:text)
    attributes.delete(:value)
    r5 = Rating.new(attributes)
    r5.valid?
    assert r5.valid?
    assert (not r5.save)
    
    # create facultative? with value
    attributes[:value] = 0.2
    r6 = Rating.new(attributes)
    assert r6.valid?
    assert r6.save
  end

  def test_assosiations
    r = Rating.first
    assert_respond_to r, :review_question
    assert_respond_to r, :destination
    assert_respond_to r, :frontend_user
    
    assert Rating.included_modules.include?(Mixins::RatingCompleteness)
    if Rails.version >= '3.0.0'
      assert Rating.instance_methods.include?(:completeness_note)
    else
      assert Rating.instance_methods.include?('completeness_note')
    end
  end

  def test_update
    # recalculate, if a user changes its rating
    r = Rating.find(2)
    ar = AggregatedRating.find_by_id(1)
    assert_equal 2, ar.user_count
    assert_equal 0.9, ar.value

    r.value = 1.0
    assert r.save

    ar = AggregatedRating.find_by_id(1)
    assert_equal 2, ar.user_count
    assert_equal 1.0, ar.value
  end

  def test_destroy
    r1 = Rating.find(1)
    r2 = Rating.find(2)
    ar = AggregatedRating.find_by_id(1)
    assert_equal 2, ar.user_count
    assert_equal 0.9, ar.value

    r1.destroy
    assert r1.frozen?

    ar = AggregatedRating.find_by_id(1)
    assert_equal 1, ar.user_count
    assert_equal 0.8, ar.value

    r2.destroy
    assert r2.frozen?

    ar = AggregatedRating.find_by_id(1)
    assert ar.nil?
  end

  private

  def valid_attributes(add_attributes={})
    {
      :review_question => @rq1_at_list,
      :value         => 0.2,
      :review        => @r1
    }.merge(add_attributes)
  end
end
