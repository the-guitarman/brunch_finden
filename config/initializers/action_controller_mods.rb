module ActionController
  module Translation
    # Returns a translation.
    # The method modifies the key, if it gets one key only and
    # the key starts with a dot (e.g. c_t('.saved_successfully')). In this case
    # the update method of the frontend users controller will return
    # the translation for: 'frontend.users.update.saved_successfully'
    def controller_translate(*args)
      if args.length == 1 and args.first.is_a?(String) and args.first.start_with?('.')
        key = args.first
        klass = self.class.name.underscore.gsub!('_controller', '').gsub('/', '.')
        aktion = action_name
        unless klass.blank? and aktion.blank? and key.blank?
          args[0] = "#{klass}.#{aktion}#{key}"
        end
      end
      I18n.translate(*args)
    end
    alias :c_t :controller_translate
  end
  
  module Caching
    module Pages
      module ClassMethods

        def expire_page(path)
          return unless perform_caching
          filename = page_cache_file(path)
          benchmark "Expired page: #{page_cache_file(path)}" do
            PAGE_CACHE_PATHS.each do |key, path_prefix|
              file = "#{page_cache_directory}/#{path_prefix}#{filename}"
              File.delete(file) if File.exist?(file)
            end
          end
        end
        
        def cache_page(content, path)
          return unless perform_caching

          benchmark "Cached page: #{page_cache_file(path)}" do
            FileUtils.makedirs(File.dirname(page_cache_path(path)))
            File.open(page_cache_path(path), "wb+") { |f| f.write(content) }
          end
        end
        
        def caches_page(*actions)
          return unless perform_caching
          options = actions.extract_options!
          
          before_filter({:only => actions}.merge(options)) { |c| 
            path = case options
              when Hash
                c.url_for(options.merge(:only_path => true, :skip_relative_url_root => true, :format => c.params[:format]))
              when String
                options
              else
                c.request.path
            end
            
            if File.exist?(page_cache_path(path))
              c.send(:render, {:text => File.open(page_cache_path(path), 'r').read}) #return File.exist?(page_cache_path(path))
            end
          }
          after_filter({:only => actions}.merge(options)) { |c| c.cache_page }
        end

      end
    end
  end
end



#module ActionController #:nodoc:
#  module Caching
#    module Fragments
#      def fragment_cache_key(key)
#puts "---- acf 6: #{key}"
#        ret = ActiveSupport::Cache.expand_cache_key(key.is_a?(Hash) ? url_for(key).split("://").last : key, :views)
#puts "---- acf 7: #{ret}"
#        ret
#      end
#
#      def fragment_for(buffer, name = {}, options = nil, &block) #:nodoc:
#        if perform_caching
#          if cache = read_fragment(name, options)
#            buffer.safe_concat(cache.html_safe)
#          else
#            pos = buffer.length
#            block.call
#            write_fragment(name, buffer[pos..-1], options)
#          end
#        else
#          block.call
#        end
#      end
#      
#      def read_fragment(key, options = nil)
#        return unless cache_configured?
#
#        self.class.benchmark "Cached fragment hit: #{key}" do
#puts "---- acf 4: #{key}"
#          key = fragment_cache_key(key)
#        begin
#          raise
#        rescue Exception => e
#          puts "#{e.message}\n\n#{e.backtrace.join("\n")}\n\n"
#        end
#puts "---- acf 5: #{key}"
#          result = cache_store.read(key, options)
#          result.respond_to?(:html_safe) ? result.html_safe : result
#        end
#      end
#      
#      # Check if a cached fragment from the location signified by <tt>key</tt> exists (see <tt>expire_fragment</tt> for acceptable formats)
#      def fragment_exist?(key, options = nil)
#puts "---- acf 1: #{key}"
#        return unless cache_configured?
#puts "---- acf 2: #{key}"
#        key = fragment_cache_key(key)
#puts "---- acf 3: #{key}"
#        self.class.benchmark "Cached fragment exists?: #{key}" do
#          cache_store.exist?(key, options)
#        end
#      end
#    end
#  end
#end
#
#
#
#module ActiveSupport #:nodoc:
#  module Cache
#    def self.expand_cache_key(key, namespace = nil)
#      expanded_cache_key = namespace ? "#{namespace}/" : ""
#puts "++++ 1: #{expanded_cache_key}"
#
#      if ENV["RAILS_CACHE_ID"] || ENV["RAILS_APP_VERSION"]
#        expanded_cache_key << "#{ENV["RAILS_CACHE_ID"] || ENV["RAILS_APP_VERSION"]}/"
#      end
#      
#puts "++++ 2: #{expanded_cache_key}"
#
#      expanded_cache_key << case
#        when key.respond_to?(:cache_key)
#          key.cache_key
#        when key.is_a?(Array)
#          key.collect { |element| expand_cache_key(element) }.to_param
#        when key
#          key.to_param
#        end.to_s
#      
#puts "++++ 3: #{expanded_cache_key}"
#
#      expanded_cache_key
#    end
#  end
#end
#
#
#module ActionController
#  module Caching
#    module Actions
#      module ClassMethods
#        # Declares that +actions+ should be cached.
#        # See ActionController::Caching::Actions for details.
#        def caches_action(*actions)
#          return unless cache_configured?
#          options = actions.extract_options!
#          puts "---- ca options: #{options.inspect}"
#          filter_options = { :only => actions, :if => options.delete(:if), :unless => options.delete(:unless) }
#          puts "---- ca filter_options: #{filter_options.inspect}"
#
#          cache_filter = ActionCacheFilter.new(:layout => options.delete(:layout), :cache_path => options.delete(:cache_path), :store_options => options)
#          puts "---- ca cache_filter: #{filter_options.inspect}"
#          around_filter(filter_options) do |controller, action|
#            cache_filter.filter(controller, action)
#          end
#        end
#      end
#      
#      protected
#        def expire_action(options = {})
#          return unless cache_configured?
#          puts "---- ea 1 options: #{options.inspect}"
#          if options[:action].is_a?(Array)
#            options[:action].dup.each do |action|
#              key = ActionCachePath.path_for(self, options.merge({ :action => action }), false)
#              puts "---- ea 2: #{key.inspect}"
#              expire_fragment(key)
#            end
#          else
#            key = ActionCachePath.path_for(self, options, false)
#            puts "---- ea 3: #{key.inspect}"
#            expire_fragment(key)
#          end
#        end
#
#      class ActionCacheFilter #:nodoc:
#        def before(controller)
#          puts "---- acf /: #{@options.inspect}"
#          puts "---- acf 0: #{@options.slice(:cache_path).inspect}"
#          pof = path_options_for(controller, @options.slice(:cache_path))
#          puts "---- acf 1: #{pof.inspect}"
#          cache_path = ActionCachePath.new(controller, pof)
#          puts "---- acf 2: #{cache_path.inspect}"
#          if cache = controller.read_fragment(cache_path.path, @options[:store_options])
#            controller.rendered_action_cache = true
#            set_content_type!(controller, cache_path.extension)
#            options = { :text => cache }
#            options.merge!(:layout => true) if cache_layout?
#            controller.__send__(:render, options)
#            false
#          else
#            controller.action_cache_path = cache_path
#          end
#        end
#        
##        def after(controller)
##          puts "---- acf 1: #{controller.rendered_action_cache.inspect}"
##          return if controller.rendered_action_cache || !caching_allowed(controller)
##          action_content = cache_layout? ? content_for_layout(controller) : controller.response.body
##          puts "---- acf 2.1: #{controller.action_cache_path.path.inspect}"
##          puts "---- acf 2.2: #{action_content.inspect}"
##          puts "---- acf 2.3: #{@options[:store_options].inspect}"
##          controller.write_fragment(controller.action_cache_path.path, action_content, @options[:store_options])
##        end
#      end
#      
#      class ActionCachePath
#        def extract_extension(request)
#            # Don't want just what comes after the last '.' to accommodate multi part extensions
#            # such as tar.gz.
#            @extension = request.path[/^[^.]+\.(.+)$/, 1] || request.cache_format
#            puts "---- acp ee 1: #{@extension.inspect}"
#            @extension
#          end
#      end
#    end
#  end
#end