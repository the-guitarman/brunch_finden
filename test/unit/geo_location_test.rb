#encoding: utf-8
require 'test_helper'

class GeoLocationTest < ActiveSupport::TestCase
  # process before each test method
  def setup

  end

  # process after each test method
  def teardown

  end

  def test_01_create
    GeoLocation.delete_all

    test_gl_1 = GeoLocation.create
    assert !test_gl_1.valid?
    assert test_gl_1.errors.invalid?(:geo_code_id)
    assert test_gl_1.errors.invalid?(:geo_code_type)
    assert test_gl_1.errors.invalid?(:lat)
    assert test_gl_1.errors.invalid?(:lng)

    attributes = valid_geo_location_attributes({
      :geo_code_id => nil,
      :lat => nil,
      :lng => 'abc'
    })
    test_gl_2 = GeoLocation.create(attributes)
    assert !test_gl_2.valid?
    assert test_gl_2.errors.invalid?(:geo_code_id)
    assert !test_gl_2.errors.invalid?(:geo_code_type)
    assert test_gl_2.errors.invalid?(:lat)
    assert test_gl_2.errors.invalid?(:lng)

    attributes = valid_geo_location_attributes({
      :geo_code_id => ''
    })
    test_gl_3 = GeoLocation.create(attributes)
    assert !test_gl_3.valid?
    assert test_gl_3.errors.invalid?(:geo_code_id)
    assert !test_gl_3.errors.invalid?(:geo_code_type)
    assert !test_gl_3.errors.invalid?(:lat)
    assert !test_gl_3.errors.invalid?(:lng)

    attributes[:geo_code_id] = -1
    test_gl_4 = GeoLocation.create(attributes)
    assert !test_gl_4.valid?
    assert test_gl_4.errors.invalid?(:geo_code_id)

    attributes[:geo_code_id] = 0
    test_gl_5 = GeoLocation.create(attributes)
    assert !test_gl_5.valid?
    assert test_gl_5.errors.invalid?(:geo_code_id)

    attributes[:geo_code_type] = -1
    test_gl_6 = GeoLocation.create(attributes)
    assert !test_gl_6.valid?
    assert test_gl_6.errors.invalid?(:geo_code_id)

    attributes = valid_geo_location_attributes
    test_gl_7 = GeoLocation.create(attributes)
    assert test_gl_7.valid?
    assert !test_gl_7.errors.invalid?(:geo_code_id)

    # check for duplicate ...
    test_gl_8 = GeoLocation.create(attributes)
    assert !test_gl_8.valid?
    assert test_gl_8.errors.invalid?(:geo_code_id)

    # ... but other object is ok
    attributes[:geo_code_type] = 'City'
    test_gl_9 = GeoLocation.create(attributes)
    assert test_gl_9.valid?
    assert !test_gl_9.errors.invalid?(:geo_code_id)
  end

  def test_02_model_relations
    GeoLocation.delete_all

    gl = GeoLocation.create(valid_geo_location_attributes)
    assert_respond_to gl, :geo_code
  end

  def test_03_update
    GeoLocation.delete_all

    gl1 = GeoLocation.create(valid_geo_location_attributes)
    assert gl1.valid?
    gl2 = GeoLocation.create(valid_geo_location_attributes({:geo_code_id => 2}))
    assert gl2.valid?

    # geo_code_id
    temp = gl1.geo_code_id
    gl1.geo_code_id = nil
    assert !gl1.save
    gl1.geo_code_id = ''
    assert !gl1.save
    gl1.geo_code_id = 'abc'
    assert !gl1.save
    gl1.geo_code_id = -1
    assert !gl1.save
    gl1.geo_code_id = 0
    assert !gl1.save
    gl1.geo_code_id = temp
    assert gl1.save

    # geo_code_type
    temp = gl1.geo_code_type
    gl1.geo_code_type = nil
    assert !gl1.save
    gl1.geo_code_type = ''
    assert !gl1.save
    gl1.geo_code_type = -1
    assert !gl1.save
    gl1.geo_code_type = temp
    assert gl1.save

    # lat
    temp = gl1.lat
    gl1.lat = nil
    assert !gl1.save
    gl1.lat = 'abc'
    assert !gl1.save
    gl1.lat = temp
    assert gl1.save

    # lng
    temp = gl1.lng
    gl1.lng = nil
    assert !gl1.save
    gl1.lng = 'abc'
    assert !gl1.save
    gl1.lng = temp
    assert gl1.save

    # check for duplicate ...
    temp = gl1.geo_code_id
    gl1.geo_code_id = gl2.geo_code_id
    assert !gl1.save
    gl1.geo_code_id = temp
    assert gl1.save
  end

  def test_04_destroy
    GeoLocation.delete_all

    gl = GeoLocation.create(valid_geo_location_attributes)

    gl.destroy
    assert gl.frozen?
  end

  def test_05_geocode
    GeoLocation.delete_all
    
    gl = GeoLocation.create(valid_geo_location_attributes)
    assert gl.geocode("Aue 23-27, 09112, Chemnitz")
    assert gl.changes.include?('lat')
    assert gl.changes.include?('lng')
  end

#  def test_06_self_geocode
#    nl = GeoLocation.geocode("Aue 23-27, 09112, Chemnitz")
#    assert nl.success?
#    assert nl.instance_of?(Geokit::GeoLoc)
#  end

#  def test_07_reverse_geo_location_to_address
#    GeoLocation.delete_all
#
#    street = 'Aue 23-27'
#    zip = '09112'
#    town = 'Chemnitz'
#
#    nl = GeoLocation.geocode("#{street}, #{zip}, #{town}")
#    assert nl.success?
#    gl = GeoLocation.create(valid_geo_location_attributes({:lat => nl.lat, :lng => nl.lng}))
#    assert gl.valid?
#
#    location = gl.reverse_geocode
#    full_address = location.full_address
#    assert full_address.include?(street[0..2])
#    assert full_address.include?(zip)
#    assert (full_address.include?(town) or full_address.include?('Karl-Marx-Stadt'))
#
#    temp_lat = (nl.lat * 10000).to_i
#    assert ((temp_lat-10)..(temp_lat+10)).include?((location.lat * 10000).to_i)
#    temp_lng = (nl.lng * 10000).to_i
#    assert ((temp_lng-10)..(temp_lng+10)).include?((location.lng * 10000).to_i)
#    temp = location.street_address
#    assert_equal street.split(' ').first, temp.split(' ').first
#    assert_equal nl.street_number, location.street_number
#    assert_equal zip, location.zip
#    town_array = ['Karl Marx Stadt']
#    town_array << town
#    assert town_array.include?(location.city)
#    assert_equal nl.state, location.state
#    assert_equal nl.district, location.district
#    assert_equal nl.country, location.country
#    assert_equal nl.province, location.province
#    assert_equal nl.accuracy, location.accuracy 
#
#    assert_equal nl.precision, location.precision
#    assert_equal nl.country_code, location.country_code
#  end

  private

  def valid_geo_location_attributes(add_attributes={})
    {
      :geo_code_id => 1,
      :geo_code_type => 'ZipCode',
      :lat => 53.462,
      :lng => -2.86739
    }.merge(add_attributes)
  end
end