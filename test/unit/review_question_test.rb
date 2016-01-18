#encoding: utf-8
require 'test_helper'

class ReviewQuestionTest < ActiveSupport::TestCase
  should have_many(:ratings).dependent(:destroy)
  should have_many(:aggregated_ratings).dependent(:destroy)
  should have_many(:review_template_questions).dependent(:destroy)
  should have_many(:review_templates)
  should have_many(:review_answers).dependent(:destroy)
  
  should validate_presence_of(:text)

  def test_01_create
    # Testing of
    # - model relations
    # - validations
    # - save

    # model relations
    review_question = ReviewQuestion.new(valid_attributes)
    assert review_question.save
    assert_respond_to review_question, :review_answers
    
    review_question = ReviewQuestion.create(
      valid_attributes({:answer_type => 'list', :analyzable => true})
    )
    assert review_question.valid?
    assert_equal true, review_question.analyzable
    
    review_question = ReviewQuestion.create(
      valid_attributes({:answer_type => 'list', :analyzable => false})
    )
    assert review_question.valid?
    assert_equal false, review_question.analyzable
    
    review_question = ReviewQuestion.create(
      valid_attributes({:answer_type => 'boolean', :analyzable => true})
    )
    assert review_question.valid?
    assert_equal false, review_question.analyzable
    
    review_question = ReviewQuestion.create(
      valid_attributes({:answer_type => 'text', :analyzable => true})
    )
    assert review_question.valid?
    assert_equal false, review_question.analyzable

    # validations
    ## presence_of
    affected_attrs = [:text]
    affected_attrs.each do |attr|
      attributes = valid_attributes
      attributes[attr] = nil
      review_question = ReviewQuestion.new(attributes)
      assert !review_question.valid?
      assert review_question.errors[attr].any?
    end

    ## inclusion_of answer_type
    invalid_values = [nil, 'hallo', 'schnulli']
    invalid_values.each do |val|
      attributes = valid_attributes
      attributes[:answer_type] = val
      review_question = ReviewQuestion.new(attributes)
      assert !review_question.valid?
      assert review_question.errors[:answer_type].any?
    end
  end

  def test_02_constants_and_associations
    assert ReviewQuestion.constants.include?('ANSWER_TYPES')
    assert ReviewQuestion::ANSWER_TYPES.is_a?(Array)
    assert_equal 3, ReviewQuestion::ANSWER_TYPES.length
    assert ReviewQuestion::ANSWER_TYPES.include?('list')
    assert ReviewQuestion::ANSWER_TYPES.include?('boolean')
    assert ReviewQuestion::ANSWER_TYPES.include?('text')
  end

  private

  def valid_attributes(add_attributes={})
    {
      :text => 'Zuverlässigkeit',
      :answer_type => 'list',
      :analyzable => true
    }.merge(add_attributes)
  end
end
