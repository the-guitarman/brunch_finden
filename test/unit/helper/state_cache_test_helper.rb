# encoding: utf-8
require 'fileutils'
require 'unit/helper/cache_test_helper'

module StateCacheTestHelper
  include CacheTestHelper
  
  def create_state_cache_paths(state)
    process_state_paths(state){|path| create_action_cache(path)}
  end
  
  def delete_state_cache_paths(state)
    process_state_paths(state){|path| delete_action_cache(path)}
  end
  
  def check_state_cache_paths_do_exist(state)
    process_state_paths(state){|path| action_cache_exist?(path)}
  end
  
  def check_state_cache_paths_do_not_exist(state)
    process_state_paths(state){|path| action_cache_does_not_exist?(path)}
  end
  
  private
  
  def process_state_paths(state, &block)
    state.city_chars.each do |cc|
      path = state_rewrite_path(
        create_rewrite_hash(state.rewrite).merge({
          city_char_parameter => cc.start_char.upcase
        })
      )
      block.call(path)
    end
  end
end