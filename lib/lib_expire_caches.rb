module LibExpireCaches
  def self.included(klass)
    klass.instance_eval do
      #extend ClassMethods
      include InstanceMethods
    end
  end
  
  module InstanceMethods    
    def expire_page(options = {})
      cb = ActionController::Base.new
      if options.is_a?(String)
        PAGE_CACHE_PATHS.each do |key, path_prefix|
          cb.expire_page("/#{path_prefix}#{options}")
        end
      end
      cb.expire_page(options)
    end
    
#    def expire_action(options = {})
#      ActionController::Base.new.send(:expire_action, options)
#    end

    def expire_fragment(key, options = nil)
      ActionController::Base.new.expire_fragment(key, options)
    end
    
#    def expire_page(path)
#      App.expire_page(path)
#    end
#    
#    def expire_action(key, options = {})
#      App.expire_action(key, options)
#    end
#
#    def expire_fragment(key, options = {})
#      App.expire_fragment(key, options)
#    end

    def get_rewrites(object)
      rewrites = []
      if object.changes.include?('rewrite')
        rewrite = object.changes['rewrite'][0]
        rewrites << rewrite if rewrite
        rewrite = object.changes['rewrite'][1]
        rewrites << rewrite if rewrite
      else
        rewrites << object.rewrite
      end
      rewrites.uniq!
      rewrites.compact!
      return rewrites
    end

    def get_rewrite_hashes(object)
      rewrite_hashes = []
      get_rewrites(object).each do |rewrite|
        rewrite_hashes << create_rewrite_hash(rewrite)
      end
      return rewrite_hashes
    end
    
    def cache_page(path)
#      puts "---------------------- 1 cache page: #{path}"
      if ActionController::Base.perform_caching == true
#        puts "---------------------- 2 ActionController::Base.perform_caching: #{ActionController::Base.perform_caching}"
        thread = Thread.new do
          if path.start_with?('/')
            fec = CustomConfigHandler.instance.frontend_config
            cache_this = "http://#{fec['DOMAIN']['FULL_NAME']}#{path}"
          else
            cache_this = path
          end
#          puts "---------------------- 3 cache this: #{cache_this}"
          app.get cache_this
        end
        thread.join
      end
    end
    
    def app
      unless defined?(@@app)
        @@app = ActionController::Integration::Session.new
        fec = CustomConfigHandler.instance.frontend_config
        @@app.host = fec['DOMAIN']['FULL_NAME']
      end
      return @@app
    end
  end
end