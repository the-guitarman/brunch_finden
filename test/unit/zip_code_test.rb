#encoding: utf-8
require 'test_helper'

class ZipCodeTest < ActiveSupport::TestCase
  # TODO: test zip_code.do_not_geocode

  # process before each test method
  def setup

  end

  # process after each test method
  def teardown

  end

  def test_01_create
    ZipCode.delete_all

    test_zc1 = ZipCode.create
    assert !test_zc1.valid?
    assert test_zc1.errors.invalid?(:city)
    assert test_zc1.errors.invalid?(:code)
    assert !test_zc1.errors.invalid?(:number_of_locations)

    zc1 = ZipCode.create(valid_attributes)
    assert zc1.valid?
    assert !zc1.city.nil?
    assert zc1.locations.empty?
    assert !zc1.geo_location.nil?
    assert_equal 0, zc1.number_of_locations
    assert_equal 1, zc1.delta

    ZipCode.delete_all
    zc2 = ZipCode.create(valid_attributes({:do_not_geocode => true}))
    assert zc2.valid?
    assert !zc2.city.nil?
    assert zc2.locations.empty?
    assert zc2.geo_location.nil?
    assert_equal 0, zc2.number_of_locations
    assert_equal 1, zc2.delta

    test_zc2 = ZipCode.create(valid_attributes)
    assert !test_zc2.valid?
    assert !test_zc2.errors.invalid?(:city)
    assert test_zc2.errors.invalid?(:code)
    assert !test_zc2.errors.invalid?(:number_of_locations)
  end

  def test_02_model_relations
    zc = ZipCode.first
    assert_respond_to zc, :city
    assert_respond_to zc, :locations
    assert_respond_to zc, :geo_location
  end

  def test_03_update
    ZipCode.delete_all
  end

  def test_04_destroy
    zc = ZipCode.first
    assert !zc.city.nil?

    zc.destroy
    assert zc.frozen?
    assert !zc.city.nil?
    zc.locations.each do |l|
      assert l.frozen?
    end
    zc.geo_location.frozen?
  end

  private

  def valid_attributes(add_attributes={})
    {
      :city_id => 1,
      :code => '09114'
    }.merge(add_attributes)
  end
end