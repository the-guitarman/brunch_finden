#encoding: utf-8
require 'test_helper'

class ReviewLockingTest < ActiveSupport::TestCase
  should belong_to :review
  
  def test_create
    ActionMailer::Base.deliveries = []
    review = Review.first
    review_state = review.state
    
    review_locking = ReviewLocking.create
		assert !review_locking.valid?
    assert review_locking.errors[:state].any?
    assert review_locking.errors[:review].any?
    assert review_locking.errors[:reason].any?
    assert ActionMailer::Base.deliveries.empty?
    
    review.review_locking = review_locking
    assert !review_locking.valid?
    assert review_locking.errors[:state].any?
    assert !review_locking.errors[:review].any?
		assert review_locking.errors[:reason].any?
    assert !review_locking.save
    assert ActionMailer::Base.deliveries.empty?
    
    review_locking.state = review_state
		review_locking.reason = 'for that reason'
		assert review_locking.valid?
    assert_equal review_state, review_locking.state
    
		assert review_locking.save
    #assert_equal 1, ActionMailer::Base.deliveries.length
    assert_equal 0, ActionMailer::Base.deliveries.length
  end
end
