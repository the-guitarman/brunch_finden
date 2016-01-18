#encoding: utf-8
require 'test_helper'

class PathToCacheTest < ActiveSupport::TestCase
  should validate_presence_of(:path).with_message(/is required/)
  context "path has to be unique" do
    subject {PathToCache.first}
    should validate_uniqueness_of(:path) #.with_message(/Please login or enter your email and name\./)
  end

  def test_find_or_create
    PathToCache.delete_all
    
    ptc_1_1 = PathToCache.find_or_create('/locations/all')
    assert ptc_1_1.valid?
    assert_equal 1, PathToCache.count
    assert_equal 1, ptc_1_1.expired_count
    
    ptc_1_2 = PathToCache.find_or_create('/locations/all')
    assert ptc_1_2.valid?
    assert_equal 1, PathToCache.count
    assert_equal 2, ptc_1_2.expired_count
    
    ptc_2_1 = PathToCache.find_or_create('/locations/2')
    assert ptc_2_1.valid?
    assert_equal 2, PathToCache.count
    assert_equal 1, ptc_2_1.expired_count
    
    ptc_2_2 = PathToCache.find_or_create('/locations/2')
    assert ptc_2_2.valid?
    assert_equal 2, PathToCache.count
    assert_equal 2, ptc_2_2.expired_count
  end
end