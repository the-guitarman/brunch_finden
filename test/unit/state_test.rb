#encoding: utf-8
require 'test_helper'

require 'unit/helper/cache_test_helper'
require 'unit/helper/state_cache_test_helper'

class StateTest < ActiveSupport::TestCase
  include StateCacheTestHelper
  
  # TODO: test change rewrite
  
  # process before each test method
  def setup

  end

  # process after each test method
  def teardown

  end

  def test_01_create
    State.delete_all

    test_s1 = State.create
    assert !test_s1.valid?
    assert test_s1.errors.invalid?(:name)
    assert test_s1.errors.invalid?(:rewrite)
    assert !test_s1.errors.invalid?(:number_of_locations)

    s1 = State.create(valid_attributes)
    assert s1.valid?
    assert !s1.errors.invalid?(:name)
    assert !s1.errors.invalid?(:rewrite)
    assert_equal 'sachsen', s1.rewrite
    assert !s1.errors.invalid?(:number_of_locations)
    assert s1.cities.empty?
    assert_equal 0, s1.number_of_locations
    assert_equal 1, s1.delta

    test_s2 = State.create(valid_attributes)
    assert !test_s2.valid?
    assert test_s2.errors.invalid?(:name)
    assert !test_s2.errors.invalid?(:rewrite)
    assert !test_s2.errors.invalid?(:number_of_locations)

    attributes = valid_attributes
    attributes[:name] = attributes[:name] + '-2'
    attributes[:rewrite] = 'my-rewrite'
    s2 = State.create(attributes)
    assert s2.valid?
    assert !s2.errors.invalid?(:name)
    assert !s2.errors.invalid?(:rewrite)
    assert_equal 'my-rewrite', s2.rewrite

    attributes[:name] = attributes[:name] + '-3'
    attributes[:rewrite] = 'my-rewrite'
    test_s3 = State.create(attributes)
    assert !test_s3.valid?
    assert !test_s3.errors.invalid?(:name)
    assert test_s3.errors.invalid?(:rewrite)
  end

  def test_02_model_relations
    s = State.first
    assert_respond_to s, :cities
  end

  def test_03_update
    s = State.first

    create_cache_files(s)

    old_rewrite = s.rewrite
    s.rewrite = "new-state-rewrite"
    assert s.save

    check_cache_files_do_not_exist(s)

    f1 = Forwarding.find(:all, :conditions => {
      :source_url => state_rewrite_path(create_rewrite_hash(old_rewrite)),
      :destination_url => state_rewrite_path(create_rewrite_hash('new-state-rewrite'))
    })
    assert !f1.empty?
    assert_equal 1, f1.length
  end

  def test_04_destroy
    s = State.first
    assert !s.cities.empty?

    create_cache_files(s)

    f1 = Forwarding.create({
      :source_url => 'my-rewrite',
      :destination_url => state_rewrite_path(create_rewrite_hash(s.rewrite))
    })
    assert f1.valid?

    s.destroy
    assert s.frozen?
    s.cities.each do |c|
      assert c.frozen?
    end

    check_cache_files_do_not_exist(s)

    assert !Forwarding.find_by_id(f1.id).nil?

    f3 = Forwarding.find(:all, :conditions => {
      :source_url => state_rewrite_path(create_rewrite_hash(s.rewrite)),
      :destination_url => root_path
    })
    assert !f3.empty?
    assert_equal 1, f3.length
  end

  private

  def valid_attributes(add_attributes={})
    {
      :name => 'Sachsen'
    }.merge(add_attributes)
  end

  def create_cache_files(state)
    create_state_cache_paths(state)
  end

  def check_cache_files_do_not_exist(state)
    check_state_cache_paths_do_not_exist(state)
  end
end