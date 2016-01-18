#encoding: utf-8
require 'test_helper'

class ReviewAnswerTest < ActiveSupport::TestCase
  fixtures :review_answers
  fixtures :review_questions

  should belong_to(:review_question)
  
  should validate_presence_of(:text).with_message('is required')
  should validate_presence_of(:score).with_message('is required')
  should validate_presence_of(:review_question_id).with_message('is required')
  
#  subject {ReviewAnswer.first}
#  should validate_uniqueness_of(:text).scoped_to(:review_question_id)
#  should validate_uniqueness_of(:position).scoped_to(:review_question_id)
#  should validate_uniqueness_of(:score).scoped_to(:review_question_id)
  
  def test_01
    # validates presence of ...
    affected_attrs = [:text, :score, :review_question_id]
    affected_attrs.each do |attr|
      attributes = valid_attributes
      attributes[attr] = nil
      ra_test_1 = ReviewAnswer.create(attributes)
      assert !ra_test_1.valid?
      assert ra_test_1.errors[attr].any?
    end

    # validates numericality of score
    invalid_values = [nil, -1, 'a', 1.10, 2]
    invalid_values.each do |val|
      # review question answer type: list
      attributes = valid_attributes({:review_question_id => 1})
      attributes[:score] = val
      ra_test_2 = ReviewAnswer.new(attributes)
      assert !ra_test_2.valid?
      assert ra_test_2.errors[:score].any?
      
      # review question answer type: boolean
      attributes = valid_attributes({:review_question_id => 4})
      attributes[:score] = val
      ra_test_3 = ReviewAnswer.new(attributes)
      assert !ra_test_3.valid?
      assert ra_test_3.errors[:score].any?
      
      # review question answer type: text
      attributes = valid_attributes({:review_question_id => 5})
      attributes[:score] = val
      ra_test_4 = ReviewAnswer.new(attributes)
      ra_test_4.valid?
      assert !ra_test_4.valid?
      assert ra_test_4.errors[:base].any?
    end

    # save
    attributes = valid_attributes
    ra = ReviewAnswer.create(attributes)
    assert ra.valid?
		
    # validates uniqueness of ...
    
    # ... text in scope of review_question_id
    ra_test_5 = ReviewAnswer.new(attributes)
    assert !ra_test_5.valid?
    assert ra_test_5.errors[:text].any?
    
    # ... position in scope of review_question_id
    ra_test_6 = ReviewAnswer.new(attributes)
    assert !ra_test_6.valid?
    assert ra_test_6.errors[:position].any?
    
    # ... score in scope of review_question_id
    ra_test_7 = ReviewAnswer.new(attributes)
    assert !ra_test_7.valid?
    assert ra_test_7.errors[:score].any?
  end
  
  def test_model_associations
    ra = ReviewAnswer.first
    assert_respond_to ra, :review_question
  end
  
  def test_destroy
    ra = ReviewAnswer.first
    ra.destroy 
    assert ra.frozen?
  end

  private

  def valid_attributes(add_attributes = {})
    {
      :review_question_id => next_review_question_id,
      :text     => 'kompliziert & unverständlich',
      :position => next_position,
      :score    => 0.0
    }.merge(add_attributes)
  end
  
  def next_review_question_id
    if @review_question_id
      @review_question_id += 1
    else
      @review_question_id ||= 1
    end
    return @review_question_id
  end
  
  def next_position
    if @position
      @position += 1
    else
      @position ||= 5
    end
    return @position
  end
end
