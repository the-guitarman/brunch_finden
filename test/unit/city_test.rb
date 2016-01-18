#encoding: utf-8
require 'test_helper'

require 'unit/helper/city_cache_test_helper'
require 'unit/helper/state_cache_test_helper'

class CityTest < ActiveSupport::TestCase  
  include CityCacheTestHelper
  include StateCacheTestHelper
  
  # TODO: test city.do_not_geocode
  # TODO: test change rewrite
  
  # process before each test method
  def setup
    
  end

  # process after each test method
  def teardown

  end

  def test_01_create
    City.delete_all

    test_c1 = City.create
    assert !test_c1.valid?
    assert test_c1.errors.invalid?(:state)
    assert test_c1.state.nil?
    assert test_c1.errors.invalid?(:name)
    assert test_c1.errors.invalid?(:rewrite)
    assert !test_c1.errors.invalid?(:number_of_locations)

    c1 = City.create(valid_attributes)
    assert c1.valid?
    assert !c1.errors.invalid?(:state)
    assert !c1.state.nil?
    assert !c1.errors.invalid?(:name)
    assert !c1.errors.invalid?(:rewrite)
    assert_equal 'sachsen/brunch-leipzig', c1.rewrite
    assert !c1.errors.invalid?(:number_of_locations)
    assert c1.zip_codes.empty?
    assert c1.geo_locations.empty?
    assert_equal 0, c1.number_of_locations
    assert_equal 1, c1.delta

    test_c2 = City.create(valid_attributes)
    assert !test_c2.valid?
    assert !test_c2.errors.invalid?(:state)
    assert test_c2.errors.invalid?(:name)
    assert !test_c2.errors.invalid?(:rewrite)
    assert !test_c2.errors.invalid?(:number_of_locations)

    attributes = valid_attributes
    attributes[:name] = attributes[:name] + '-2'
    attributes[:rewrite] = 'my-rewrite'
    c2 = City.create(attributes)
    assert c2.valid?
    assert !c2.errors.invalid?(:name)
    assert !c2.errors.invalid?(:rewrite)
    assert_equal 'sachsen/brunch-my-rewrite', c2.rewrite

    attributes[:name] = attributes[:name] + '-3'
    attributes[:rewrite] = 'my-rewrite'
    c3 = City.create(attributes)
    assert c3.valid?
    assert !c3.errors.invalid?(:name)
    assert !c3.errors.invalid?(:rewrite)
    assert_equal 'sachsen/brunch-my-rewrite--2', c3.rewrite
  end

  def test_02_model_relations
    c = City.first
    assert_respond_to c, :state
    assert_respond_to c, :zip_codes
    assert_respond_to c, :geo_locations
    
    assert City.included_modules.include?(Mixins::RewriteSuggestion)
    assert_equal 'name',  City.generate_rewrite_from
  end

  def test_03_update
    c = City.first

    create_cache_files(c)

    old_rewrite = c.rewrite
#    c.rewrite = "#{c.state.rewrite}/new-rewrite"
    c.rewrite = "new-city-rewrite"
    assert c.save

    check_caches_do_not_exist(c)

    f1 = Forwarding.find(:all, :conditions => {
      :source_url => city_rewrite_path(create_rewrite_hash(old_rewrite)),
      :destination_url => city_rewrite_path(create_rewrite_hash("#{c.state.rewrite}/brunch-new-city-rewrite"))
    })
    assert !f1.empty?
    assert_equal 1, f1.length
  end

  def test_04_destroy
    c = City.first
    assert !c.zip_codes.empty?

    create_cache_files(c)

    f1 = Forwarding.create({
      :source_url => 'my-rewrite',
      :destination_url => city_rewrite_path(create_rewrite_hash(c.rewrite))
    })
    assert f1.valid?

    c.destroy
    assert c.frozen?
    c.zip_codes.each do |zc|
      assert zc.frozen?
    end

    check_caches_do_not_exist(c)

    assert !Forwarding.find_by_id(f1.id).nil?

    f3 = Forwarding.find(:all, :conditions => {
      :source_url => city_rewrite_path(create_rewrite_hash(c.rewrite)),
      :destination_url => state_rewrite_path(create_rewrite_hash(c.state.rewrite))
    })
    assert !f3.empty?
    assert_equal 1, f3.length
  end

  def test_05_increment_counters
    c = City.first
    c_number_of_locations = c.number_of_locations.to_i
    s_number_of_locations = c.state.number_of_locations.to_i

    c.incement_number_of_locations(1)

    c.reload
    assert_equal c_number_of_locations + 1, c.number_of_locations
    assert_equal s_number_of_locations + 1, c.state.number_of_locations

    c.stop_update_counters = true
    c.incement_number_of_locations(1)

    c.reload
    assert_equal c_number_of_locations + 2, c.number_of_locations
    assert_equal s_number_of_locations + 1, c.state.number_of_locations
  end

  def test_06_decrement_counters
    c = City.first
    c_number_of_locations = c.number_of_locations.to_i
    s_number_of_locations = c.state.number_of_locations.to_i

    c.decement_number_of_locations(1)

    c.reload
    assert_equal number_can_not_be_lesser_than_0(c_number_of_locations - 1),
      c.number_of_locations
    assert_equal number_can_not_be_lesser_than_0(s_number_of_locations - 1),
      c.state.number_of_locations

    c.stop_update_counters = true
    c.decement_number_of_locations(1)

    c.reload
    assert_equal number_can_not_be_lesser_than_0(c_number_of_locations - 2),
      c.number_of_locations
    assert_equal number_can_not_be_lesser_than_0(s_number_of_locations - 1),
      c.state.number_of_locations
  end

  private

  def valid_attributes(add_attributes={})
    {
      :state_id => 1,
      :name => 'Leipzig'
    }.merge(add_attributes)
  end

  def number_can_not_be_lesser_than_0(number)
    if number < 0
      number = 0
    end
    number
  end

  def create_cache_files(city)
    create_city_cache(city)
    create_state_cache_paths(city.state)
  end

  def check_caches_do_not_exist(city)
    check_city_cache_does_not_exist(city)
    check_state_cache_paths_do_not_exist(city.state)
  end
end