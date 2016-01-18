#encoding: utf-8
require 'test_helper'

class ClickoutTest < ActiveSupport::TestCase
  # process before each test method
  def setup
    @c = Coupon.first
  end

  # process after each test method
  def teardown

  end

  def test_01_create
    Clickout.delete_all

    test_co_1 = Clickout.create
    assert !test_co_1.valid?
    assert test_co_1.errors.invalid?(:destination_id)
    assert test_co_1.errors.invalid?(:destination_type)
    assert !test_co_1.errors.invalid?(:template)

    attributes = valid_attributes
    attributes[:destination_id] = nil
    test_co_2 = Clickout.create(attributes)
    assert !test_co_2.valid?
    assert test_co_2.errors.invalid?(:destination_id)
    assert !test_co_2.errors.invalid?(:destination_type)
    assert !test_co_2.errors.invalid?(:template)

    attributes = valid_attributes
    attributes[:destination_type] = nil
    test_co_3 = Clickout.create(attributes)
    assert !test_co_3.valid?
    assert !test_co_3.errors.invalid?(:destination_id)
    assert test_co_3.errors.invalid?(:destination_type)
    assert !test_co_3.errors.invalid?(:template)

    co = Clickout.create(valid_attributes)
    assert co.valid?
    assert !co.errors.invalid?(:destination_id)
    assert !co.errors.invalid?(:destination_type)
  end

  def test_02_constants_and_associations
    assert Clickout.constants.include?('URL_PARAMETERS')
    assert_equal 3, Clickout::URL_PARAMETERS.keys.length
    assert Clickout::URL_PARAMETERS.is_a?(Hash)
    assert Clickout::URL_PARAMETERS.has_key?(:template)
    assert_equal :a, Clickout::URL_PARAMETERS[:template]
    assert Clickout::URL_PARAMETERS.has_key?(:position)
    assert_equal :b, Clickout::URL_PARAMETERS[:position]
    assert Clickout::URL_PARAMETERS.has_key?(:platform)
    assert_equal :d, Clickout::URL_PARAMETERS[:platform]

    assert Clickout.constants.include?('DEFAULT_VALUES')
    assert Clickout::DEFAULT_VALUES.is_a?(Hash)
    assert Clickout::DEFAULT_VALUES.has_key?(:platform)

    assert Clickout.constants.include?('DO_NOT_TRACK')
    assert Clickout::DO_NOT_TRACK.is_a?(Hash)
    assert Clickout::DO_NOT_TRACK.has_key?(:user_agents)
    assert Clickout::DO_NOT_TRACK[:user_agents].is_a?(String)
    assert Clickout::DO_NOT_TRACK[:user_agents].include?('google')
    assert Clickout::DO_NOT_TRACK[:user_agents].include?('fireball')
    assert Clickout::DO_NOT_TRACK.has_key?(:ips)
    assert Clickout::DO_NOT_TRACK[:ips].is_a?(Array)
    assert Clickout::DO_NOT_TRACK[:ips].include?('124.82.93.210')

    Clickout.delete_all
    co = Clickout.create(valid_attributes)
    assert_respond_to co, :destination
  end

  def test_03_update
    Clickout.delete_all
    co = Clickout.create(valid_attributes)

    # clickout can't be changed
    co.template = 'my_not_existing_template'
    assert !co.save
  end

  def test_04_destroy
    Clickout.delete_all
    co = Clickout.create(valid_attributes)

    # clickout can't be destroyed
    co.destroy
    assert !co.frozen?
  end

  private

  def valid_attributes(add_attributes={})
    {
      :destination_id   => @c.id,
      :destination_type => @c.class.name,
      :remote_ip        => '127.0.0.1',
      :user_agent       => 'Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.1.8) Gecko/20100214 Ubuntu/9.10 (karmic) Firefox/3.5.8 FirePHP/0.4',
      :template         => 'click_at_template_name'
    }.merge(add_attributes)
  end
end
