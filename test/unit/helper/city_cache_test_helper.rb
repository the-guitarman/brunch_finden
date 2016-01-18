# encoding: utf-8
require 'fileutils'
require 'unit/helper/cache_test_helper'

module CityCacheTestHelper
  include CacheTestHelper
  
  def create_city_cache(city)
    create_action_cache(city_rewrite_cache_key(city.rewrite))
    create_action_cache(city_rewrite_cache_key(city.rewrite, {:page => 2}))
    create_action_cache(city_rewrite_cache_key(city.rewrite, {:page => 3}))
  end
  
  def check_city_cache_does_not_exist(city)
    action_cache_does_not_exist?(city_rewrite_cache_key(city.rewrite))
    action_cache_does_not_exist?(city_rewrite_cache_key(city.rewrite, {:page => 2}))
    action_cache_does_not_exist?(city_rewrite_cache_key(city.rewrite, {:page => 3}))
  end
end