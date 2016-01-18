# encoding: utf-8
require 'fileutils'
require 'unit/helper/cache_test_helper'

module LocationCacheTestHelper
  include CacheTestHelper
  
  def create_location_cache_files(location)
    rewrite_hash = create_rewrite_hash(location.rewrite)
    
    create_page_cache(location_rewrite_path(rewrite_hash))
  end
  
  def location_cache_files_exist(rewrite)
    rewrite_hash = create_rewrite_hash(rewrite)
    
    page_cache_exists?(location_rewrite_path(rewrite_hash))
  end
  
  def location_cache_files_not_exist(rewrite)
    rewrite_hash = create_rewrite_hash(rewrite)
    
    page_cache_not_exists?(location_rewrite_path(rewrite_hash))
  end
  
  def check_location_cache_does_not_exist(location)
    rewrite_hash = create_rewrite_hash(location.rewrite)
    
    page_cache_not_exists?(location_rewrite_path(rewrite_hash))
  end
end