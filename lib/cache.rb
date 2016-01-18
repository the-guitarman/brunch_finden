class Cache
  # UrlWriter used to create rewrite paths
  if Rails.version >= '3.0.0'
    include Rails.application.routes.url_helpers
  else
    include ActionController::UrlWriter
  end
  
  fec = CustomConfigHandler.instance.frontend_config
  default_url_options[:host] = fec['DOMAIN']['FULL_NAME']

  def expire_page(path)
    ActionController::Base.expire_page(path)
  end

  def expire_action(*args)
    options = args.extract_options!
    if args.first.is_a?(String)
      expire(args.first, options)
    elsif args.empty? and not options.empty?
      expire(url_for(options.merge({:only_path => true})))
    else
      raise "I don't no how to expire: #{args.inspect}"
    end
  end

  def expire_fragment(key, options={})
    expire(key, options)
  end
  
  def fragment_exist?(key, options = {})
    !read_fragment(key, options).nil?
  end
  
  def read_fragment(key, options = {})
    return unless caching_enabled?
    key = fragment_cache_key(key)
    Rails.cache.read(key, options)
  end
  
  def write_fragment(key, options = {})
    return unless caching_enabled?
    key = fragment_cache_key(key)
    Rails.cache.write(key, options)
  end

  private
  
  def caching_enabled?
    return ActionController::Base.perform_caching
  end

  def expire(key, options = {})
    #puts "-- Cache#expire - key: #{key}"
    return unless caching_enabled?
    key = fragment_cache_key(key)
    Rails.cache.delete(key, options)
  end
  
  def read_fragment(key, options = {})
    return unless caching_enabled?
    key = fragment_cache_key(key)
    Rails.cache.read(key, options)
  end

  def expand_cache_key(key)
    # if the key is a hash, then use url for
    # else use expand_cache_key like fragment caching
    to_expand = key.is_a?(Hash) ? url_for(key).split('://').last : key
    return ActiveSupport::Cache.expand_cache_key(to_expand, :views)
  end
  
  def fragment_cache_key(key)
    new_key = add_extension(key)
    return ActionController::Base.new.fragment_cache_key(new_key)
  end
  
  def add_extension(key)
    a = key.strip.split('?')
    new_key = a.join('?')
    if not (extension = File.extname(a.first)).blank? and not new_key.end_with?(extension)
      new_key += extension
    end
    return new_key
  end
end