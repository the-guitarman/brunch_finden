#encoding: utf-8
require 'test_helper'

require 'unit/helper/cache_test_helper'
require 'unit/helper/location_cache_test_helper'
require 'unit/helper/city_cache_test_helper'
require 'unit/helper/state_cache_test_helper'

class LocationTest < ActiveSupport::TestCase
  should belong_to :frontend_user
  should belong_to :zip_code
  should have_one(:geo_location).dependent(:destroy)
  
  should have_many(:images).dependent(:destroy)
  should have_many(:reviews).dependent(:destroy)
  should have_one(:aggregated_review).dependent(:destroy)
  should have_many(:aggregated_ratings).dependent(:destroy)
  
  include LocationCacheTestHelper
  include CityCacheTestHelper
  include StateCacheTestHelper
  
  # TODO: test location.do_not_geocode

  # process before each test method
  def setup

  end

  # process after each test method
  def teardown

  end

  def test_create
    Location.delete_all

    test_l1 = Location.create
    assert !test_l1.valid?
    assert test_l1.errors.invalid?(:zip_code)
    assert test_l1.errors.invalid?(:name)
    assert test_l1.errors.invalid?(:rewrite)
    assert !test_l1.errors.invalid?(:description)
    assert test_l1.errors.invalid?(:street)

    l1 = Location.create(valid_attributes)
    assert l1.valid?
    assert !l1.errors.invalid?(:name)
    assert !l1.errors.invalid?(:rewrite)
    assert_equal 'sachsen/chemnitz/cafe-moskau', l1.rewrite
    assert !l1.errors.invalid?(:description)
    assert !l1.errors.invalid?(:street)
    assert !l1.geo_location.nil?
    assert_equal 1, l1.delta

    test_l2 = Location.create(valid_attributes)
    assert !test_l2.valid?
    assert !test_l2.errors.invalid?(:zip_code)
    assert test_l2.errors.invalid?(:name)
    assert !test_l2.errors.invalid?(:rewrite)
    assert !test_l2.errors.invalid?(:description)
    assert !test_l2.errors.invalid?(:street)
    assert test_l2.geo_location.nil?

    attributes = valid_attributes
    attributes[:name] = attributes[:name] + '-2'
    attributes[:rewrite] = 'my-rewrite'
    l2 = Location.create(attributes)
    assert l2.valid?
    assert !l2.errors.invalid?(:name)
    assert !l2.errors.invalid?(:rewrite)
    assert_equal 'sachsen/chemnitz/my-rewrite', l2.rewrite

    attributes[:name] = attributes[:name] + '-3'
    attributes[:rewrite] = 'my-rewrite'
    l3 = Location.create(attributes)
    assert l3.valid?
    assert !l3.errors.invalid?(:name)
    assert !l3.errors.invalid?(:rewrite)
    assert_equal 'sachsen/chemnitz/my-rewrite--2', l3.rewrite
  end

  def test_model_relations
    l = Location.first
    assert_respond_to l, :zip_code
    assert_respond_to l, :geo_location
    
    assert l.instance_variables.include?('@do_not_geocode')
    
    assert Location.included_modules.include?(Mixins::RewriteSuggestion)
    assert_equal 'name',  Location.generate_rewrite_from
  end

  def test_update
    l = Location.first
    l.published = false
    assert l.save
    rewrite = l.rewrite

    create_cache_files(l)
    location_cache_files_exist(rewrite)
    l.name += '-'
    assert l.save
    location_cache_files_not_exist(rewrite)
    
    create_cache_files(l)
    location_cache_files_exist(rewrite)
    l.published = true
    assert l.save
    location_cache_files_not_exist(rewrite)  
    
    

    create_cache_files(l)
    location_cache_files_exist(rewrite)
    old_rewrite = String.new(l.rewrite)
    l.rewrite = "new-location-rewrite"
    location_cache_files_exist(old_rewrite)
    
    assert l.save
    location_cache_files_not_exist(old_rewrite)
    
    new_rewrite_1 = "#{l.zip_code.city.rewrite}/new-location-rewrite"
    assert_equal new_rewrite_1, l.rewrite
    
    assert l.save
    check_cache_files_do_not_exist(l)

    f1 = Forwarding.find(:all, :conditions => {
      :source_url => location_rewrite_path(create_rewrite_hash(old_rewrite)),
      :destination_url => location_rewrite_path(create_rewrite_hash(new_rewrite_1))
    })
    assert !f1.empty?
    assert_equal 1, f1.length
    
    l.name = 'ALEX in Chemnitz City'
    assert l.save
    new_rewrite_2 = "#{l.zip_code.city.rewrite}/alex-in-chemnitz-city"
    assert_equal new_rewrite_2, l.rewrite

    f1 = Forwarding.find(:all, :conditions => {
      :source_url => location_rewrite_path(create_rewrite_hash(old_rewrite)),
      :destination_url => location_rewrite_path(create_rewrite_hash(new_rewrite_1))
    })
    assert f1.empty?

    f3 = Forwarding.find(:all, :conditions => {
      :source_url => location_rewrite_path(create_rewrite_hash(old_rewrite)),
      :destination_url => location_rewrite_path(create_rewrite_hash(new_rewrite_2))
    })
    assert !f3.empty?
    assert_equal 1, f3.length

    f5 = Forwarding.find(:all, :conditions => {
      :source_url => location_rewrite_path(create_rewrite_hash(new_rewrite_1)),
      :destination_url => location_rewrite_path(create_rewrite_hash(new_rewrite_2))
    })
    assert !f5.empty?
    assert_equal 1, f5.length
  end

  def test_destroy
    l = Location.first
    assert !l.geo_location.nil?
    
    create_cache_files(l)

    f1 = Forwarding.create({
      :source_url => 'my-rewrite',
      :destination_url => location_rewrite_path(create_rewrite_hash(l.rewrite))
    })
    assert f1.valid?

    l.destroy
    assert l.frozen?
    assert l.geo_location.frozen?

    check_cache_files_do_not_exist(l)

    assert !Forwarding.find_by_id(f1.id).nil?

    f3 = Forwarding.find(:all, :conditions => {
      :source_url => location_rewrite_path(create_rewrite_hash(l.rewrite)),
      :destination_url => city_rewrite_path(create_rewrite_hash(l.zip_code.city.rewrite))
    })
    assert !f3.empty?
    assert_equal 1, f3.length
  end
  
  def test_review_template
    rt = Location.first.review_template
    assert rt.is_a?(ReviewTemplate)
    assert_equal 0, rt.destination_type
  end

  private

  def valid_attributes(add_attributes={})
    {
      :zip_code_id => 1,
      :frontend_user => FrontendUser.last,
      :name        => 'Cafe Moskau',
      :description => '',
      :street      => 'Straße der Nationen 56',
      :email       => 'axel.schweiss@cafe-moskau.de',
      :phone       => '0371 9837433',
      :price       => 6.5,
      :general_terms_and_conditions_confirmed => true
    }.merge(add_attributes)
  end

  def create_cache_files(location)
    create_location_cache_files(location)
    create_city_cache(location.zip_code.city)
    create_state_cache_paths(location.zip_code.city.state)
  end

  def check_cache_files_do_exist(location)
    check_location_cache_does_exist(location)
    check_city_cache_files_do_exist(location.zip_code.city)
    check_state_cache_paths_do_exist(location.zip_code.city.state)
  end

  def check_cache_files_do_not_exist(location)
    check_location_cache_does_not_exist(location)
    check_city_cache_does_not_exist(location.zip_code.city)
    check_state_cache_paths_do_not_exist(location.zip_code.city.state)
  end
end