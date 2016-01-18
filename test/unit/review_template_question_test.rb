#encoding: utf-8
require 'test_helper'

class ReviewTemplateQuestionTest < ActiveSupport::TestCase
  fixtures :review_templates
  fixtures :review_questions
  
  should belong_to :review_template
  should belong_to :review_question

  should validate_presence_of(:review_template_id) #.with_message("Rating is required")
  should validate_presence_of(:review_question_id) #.with_message("Rating is required")

  def test_validations
    # validates presence of ...
    affected_attrs = [:review_template_id, :review_question_id]
    affected_attrs.each do |attr|
      attributes = valid_attributes
      attributes[attr] = nil
      rtq_test_1 = ReviewTemplateQuestion.create(attributes)
      assert !rtq_test_1.valid?
      assert rtq_test_1.errors[attr].any?
    end

    # validates inclusion of obligation
    values = [nil, '']
    values.each do |val|
      attributes = valid_attributes
      attributes[:obligation] = val
      rtq_test_2 = ReviewTemplateQuestion.create(attributes)
      assert !rtq_test_2.valid?
      assert rtq_test_2.errors[:obligation].any?
    end

    # validates numericality of priority
    invalid_values = [-1, 'a']
    invalid_values.each do |val|
      attributes = valid_attributes
      attributes[:priority] = val
      rtq_test_3 = ReviewTemplateQuestion.create(attributes)
      assert !rtq_test_3.valid?
      assert rtq_test_3.errors[:priority].any?
    end

    # save
    attributes = valid_attributes
    rtq = ReviewTemplateQuestion.create(attributes)
    assert rtq.valid?
		
    # validates uniqueness of review_question_id in scope of review_template_id
    rtq = ReviewTemplateQuestion.new(attributes)
    assert !rtq.valid?
    assert rtq.errors[:review_question_id].any?
  end
  
  def test_model_associations
    rtq = ReviewTemplateQuestion.first
    assert_respond_to rtq, :review_template
    assert_respond_to rtq, :review_question
  end
  
  def test_destroy
    rtq = ReviewTemplateQuestion.first
    rtq.destroy 
    assert rtq.frozen?
  end
  
  private

  def valid_attributes(add_attributes={})
    {
      :review_template_id => 1,
      :review_question_id => next_review_question_id,
      :priority   => next_priority,
      :obligation => false
    }.merge(add_attributes)
  end
  
  def next_review_question_id
    if @review_question_id
      @review_question_id += 1
    else
      @review_question_id ||= 4
    end
    return @review_question_id
  end
  
  def next_priority
    if @priority
      @priority += 1
    else
      @priority ||= 4
    end
    return @priority
  end
end
