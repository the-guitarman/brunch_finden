#encoding: utf-8
require 'test_helper'

class ReviewTemplateTest < ActiveSupport::TestCase
  fixtures :review_templates
  
  should have_many(:review_template_questions).dependent(:destroy)

  def test_01_create
    attributes = valid_attributes

    # validations
    ## presence_of
    attributes[:name] = nil
    rt1 = ReviewTemplate.create(attributes)
    assert !rt1.valid?
    assert rt1.errors[:name].any?

    ## uniqueness_of
    attributes[:name] = ReviewTemplate.first.name
    rt1 = ReviewTemplate.create(attributes)
    assert !rt1.valid?
    assert rt1.errors[:name].any?



    ReviewTemplate.delete_all
    # create a location review template ...
    rt2 = ReviewTemplate.create(
      valid_attributes({
        :name => 'Location Review Template',
        :destination_type => ReviewTemplate::DESTINATION_TYPES.index('location')
      })
    )
    assert rt2.valid?

    # ... only one can exist
    rt3 = ReviewTemplate.create(
      valid_attributes({
        :name => 'Location Review Template',
        :destination_type => ReviewTemplate::DESTINATION_TYPES.index('location')
      })
    )
    assert (not rt3.valid?)
    assert rt3.errors[:name].any?
    assert rt3.errors[:destination_type].any?
  end

  def test_02_constants_and_associations
    assert ReviewTemplate.constants.include?('DESTINATION_TYPES')
    assert ReviewTemplate::DESTINATION_TYPES.is_a?(Hash)
    assert_equal 1, ReviewTemplate::DESTINATION_TYPES.keys.length
    assert ReviewTemplate::DESTINATION_TYPES.has_key?(0)
    assert_equal 'location', ReviewTemplate::DESTINATION_TYPES[0]

    rt = ReviewTemplate.first
    assert rt.review_template_questions.is_a?(Array)
  end

  def test_03_update
    rt = ReviewTemplate.first
    rt.destination_type = 4
    assert (not rt.save)
  end

  def test_04_destroy
    rt = ReviewTemplate.first

    rtqs = rt.review_template_questions
    assert_equal 3, rtqs.length

    rt.destroy
    assert rt.frozen?

    rtqs.each do |rtq|
      assert rtq.frozen?
    end
  end

  def valid_attributes(add_attributes={})
    {
      :name => 'Geschmack',
      :destination_type => ReviewTemplate::DESTINATION_TYPES.index('location')
    }.merge(add_attributes)
  end

end
