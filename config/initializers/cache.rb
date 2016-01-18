PAGE_CACHE_PATHS = {
  :frontend => :frontend,
  :mobile   => :mobile
}

module App
  class << self
    def cache
      @cache ||= Cache.new
    end

    def expire_fragment(*args)
      cache.expire_fragment(*args)
    end

    def expire_action(*args)
      cache.expire_action(*args)
    end

    def fragment_exist?(*args)
      cache.fragment_exist?(*args)
    end

    def read_fragment(*args)
      cache.read_fragment(*args)
    end

    def write_fragment(*args)
      cache.write_fragment(*args)
    end
  end
end

# For testing purposes, this script clears the cache and deletes other 
# cached files at rails start, if ActionController::Base.perform_caching is true. 
require 'fileutils'
   
def expire_the_whole_cache(show_messages = true)
  entries_proc = Proc.new do |path|
    if File.directory?(path)
      entries = Dir.entries(path).delete_if{|dir| ['.', '..'].include?(dir)}
      if entries.length > 0
        FileUtils.rm_r(entries.map{|dir| "#{path}/#{dir}"}, {:force => true})
        puts "== INIT: Cache - #{path}/* deleted" if show_messages
      end
    end
  end
  entries_proc.call("#{Rails.root}/public/js_cached")
  entries_proc.call("#{Rails.root}/public/css_cached")
  
  page_cache_directory = ActionController::Base.page_cache_directory
  unless page_cache_directory.start_with?(Rails.root.to_s)
    page_cache_directory = "#{Rails.root}/#{page_cache_directory}"
  end
  entries_proc.call(page_cache_directory)
  if ActionController::Base.cache_store.is_a?(ActiveSupport::Cache::MemCacheStore)
    Rails.cache.clear
    puts "== INIT: Cache - Rails.cache.clear" if show_messages
  elsif ActionController::Base.cache_store.is_a?(ActiveSupport::Cache::FileStore)
    entries_proc.call("#{Rails.root}/tmp/cache")
  else
    puts "== INIT: Cache - I don't no how to clear #{ActionController::Base.cache_store.class.name}."
  end
end
  
#if (
#  Rails.env.development? or Rails.env.development_cache? or 
#  Rails.env.production_dev? or Rails.env.test?
# ) and ActionController::Base.perform_caching == true
#  expire_the_whole_cache
#end
