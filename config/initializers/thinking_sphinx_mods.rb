## Modifications for ThinkingSphinx to suit our environment alteration.
require 'thinking_sphinx'

module ThinkingSphinx
  class Configuration
    # extend allowed sphinx.yml config options
    SourceOptions = SourceOptions + [
      'type', 'sql_host', 'sql_port', 'sql_user', 'sql_pass', 'sql_db', 'sql_sock'
    ]
    
    alias reset_old reset
    def reset(custom_app_root=nil)
      reset_old(custom_app_root)
      @configuration.indexer.mem_limit ||= "64M"
      #self.database_yml_file = "#{self.app_root}/config/environments/#{environment}/database.yml"
      self
    end

    private
    # Parse the config/sphinx.yml file - if it exists - then use the attribute
    # accessors to set the appropriate values. Nothing too clever.
    #
    # Overwrites method in real thinking sphinx plugin
    # to use our configuration file structure.
    alias parse_config_old parse_config
    def parse_config
      path = "#{app_root}/config/environments/#{environment}/sphinx.yml"
      return unless File.exists?(path)
      
      conf = YAML::load(ERB.new(IO.read(path)).result) #[environment]
      unless conf.key?("config_file")
         conf['config_file'] = "#{self.app_root}/config/environments/#{environment}/sphinx.conf"
      end
      
      #puts "-------------------- searchd_file_path - 1: #{conf['searchd_file_path']}"
      
      conf.each do |key,value|
        if self.respond_to?("#{key}=")
          self.send("#{key}=", value)
        elsif self.respond_to?("#{key}=".to_sym)
          self.send("#{key}=".to_sym, value)
        else
          Rails.logger.error("\n#{Time.now.to_s(:db)}: - Error: #{self.class.name}#respond_to?('#{key}='): #{self.respond_to?("#{key}=")} in  #{__FILE__}")
        end
        
        set_sphinx_setting self.source_options, key, value, SourceOptions
        set_sphinx_setting self.index_options,  key, value, IndexOptions
        set_sphinx_setting self.index_options,  key, value, CustomOptions
        set_sphinx_setting @configuration.searchd, key, value
        set_sphinx_setting @configuration.indexer, key, value
      end unless conf.nil?
      
      #puts "-------------------- searchd_file_path - 2: #{self.searchd_file_path}"
      
      self.bin_path += '/' unless self.bin_path.blank?
      
      if self.allow_star
        self.index_options[:enable_star]    = true
        self.index_options[:min_prefix_len] = 1
      end
    end
  end
  
  
  class Source
    module SQL
      alias sql_query_pre_for_core_old sql_query_pre_for_core
      def sql_query_pre_for_core
        if Rails.env.rc?
          [""]
        else
          sql_query_pre_for_core_old
        end
      end
    end
  end

  class AbstractAdapter
    #dirty fix to accept Octopus::Proxy as Adapter
    #Will only work for MySQL
    def self.detect(model)
      adapter = adapter_for_model model
      case adapter
      when :mysql 
        ThinkingSphinx::MysqlAdapter.new model
      when "Octopus::Proxy"
        ThinkingSphinx::MysqlAdapter.new model
      when :postgresql
        ThinkingSphinx::PostgreSQLAdapter.new model
      when Class
        adapter.new model
      else
        raise "Invalid Database Adapter: Sphinx only supports MySQL and PostgreSQL, not #{adapter}"
      end
    end
  end
end

# total pages bugfix to use search results with will paginate
module ThinkingSphinx
  class Search
    def total_pages
      populate
      # original
      #return 0 if @results[:total].nil?
      #@total_pages ||= (@results[:total] / per_page.to_f).ceil
      # bugfix
      return 0 if @results[:total_found].nil?
      @total_pages ||= (@results[:total_found] / per_page.to_f).ceil
    end
  end
end

module ThinkingSphinx
  module Deltas
    class DefaultDelta
      def index(model, instance = nil)
        #puts "-- model: #{model.inspect}"
        #puts "-- instance: #{instance.inspect}"
        #puts "-- toggled: #{toggled(instance).inspect}"
        #puts "-- @column: #{@column.inspect}"
        #puts "-- read attr: #{instance.read_attribute(@column).inspect}"
        #puts
        
        return true unless ThinkingSphinx.updates_enabled? &&
          ThinkingSphinx.deltas_enabled?
        return true if instance && !toggled(instance)
        
        # if the instance has a delta ONLY ...
        # ... update delta indexes if sphinx is not remote
        # ... delete the instance from the core
        delta = toggled(instance)
        if instance and (delta.is_a?(TrueClass) or (delta.is_a?(Fixnum) and delta > 0))
          Rails.logger.info "thinking sphinx mods - delete_from_core: #{model.name}, instance"
          update_delta_indexes model unless ThinkingSphinx.remote_sphinx?
          delete_from_core(model, instance) #if instance
        else
          Rails.logger.info "thinking sphinx mods - do not delete_from_core: #{model.name}, instance"
        end
        
        true
      end
     
      alias old_initialize initialize
      def initialize(index, options)
        old_initialize(index, options)
        @indexer_mutex=Mutex.new
      end
     
      alias old_index index
      def index(model, instance = nil)
        @indexer_mutex.synchronize do
          old_index(model, instance)
        end
      end
    end
  end
end

module ThinkingSphinx
  module ActiveRecord
    module AttributeUpdates
      private
      
      def update_attribute_values
        return true unless ThinkingSphinx.updates_enabled? &&
          ThinkingSphinx.sphinx_running?
        
        self.class.sphinx_indexes.each do |index|
          if delta_object = index.delta_object
            delta = delta_object.toggled(self)
            unless (delta.is_a?(TrueClass) or (delta.is_a?(Fixnum) and delta > 0))
              return true
            end
          end
          
          attribute_pairs  = attribute_values_for_index(index)
          attribute_names  = attribute_pairs.keys
          attribute_values = attribute_names.collect { |key|
            attribute_pairs[key]
          }
          
          Rails.logger.info "-- update_attribute_values: update_index #{index.core_name}, #{attribute_names.inspect}, #{attribute_values.inspect}"
          update_index index.core_name, attribute_names, attribute_values
          next unless index.delta?
          Rails.logger.info "-- update_attribute_values: update_index #{index.delta_name}, #{attribute_names.inspect}, #{attribute_values.inspect}"
          update_index index.delta_name, attribute_names, attribute_values
        end
        
        true
      end
    end
  end
end

module ThinkingSphinx
  module SearchMethods
    module ClassMethods
      alias standard_search search
      def search(*args)
        args_clone = args.clone
        option_hash = args_clone.extract_options!
        search_query = args_clone.first

        convert_string_and_symbol_filter_values_to_crc32(option_hash)

        begin
          result = standard_search(search_query, option_hash)
          if option_hash[:ignore_errors] == true and result.error?
            msg = "#{__FILE__} - search()\n\n" +
              "args: #{args.inspect}\n\n" +
              "Error in ThinkingSphinx Mods search(): #{result.error.inspect}\n\n" +
              "result: #{result.inspect}"
            Mailers::AdminMailer.deliver_report_error(msg)
            result = []
          end
          return result
        rescue Exception => e
          msg = "#{__FILE__} - search()\n\n" +
            "args: #{args.inspect}\n\n" +
            "Exception in ThinkingSphinx Mods search()\n\n" +
            "#{e.message}\n\n" + 
            e.backtrace.join("\n")
          Mailers::AdminMailer.deliver_report_error(msg)
          return []
        end
      end

      alias standard_search_count search_count
      def search_count(*args)
        args_clone = args.clone
        option_hash = args_clone.extract_options!
        search_query = args_clone.first
        
        convert_string_and_symbol_filter_values_to_crc32(option_hash)
        
        begin
          result = standard_search_count(search_query, option_hash)
          if option_hash[:ignore_errors] == true and result.error?
            msg = "#{__FILE__} - search_count()\n\n" +
              "args: #{args.inspect}\n\n" +
              "Error in ThinkingSphinx Mods search_count(): #{result.error.inspect}\n\n" +
              "result: #{result.inspect}"
            AdminMailer.report_error(msg).deliver
            result = 0
          end
          return result
        rescue Exception => e
          msg = "#{__FILE__} - search_count()\n\n" +
            "args: #{args.inspect}\n\n" +
            "Exception in ThinkingSphinx Mods search_count()\n\n" +
            "#{e.message}\n\n" + 
            e.backtrace.join("\n")
          AdminMailer.report_error(msg).deliver
          return 0
        end
      end

      # This function checks with and without filter in the option_hash an processes
      # each item of them with filter_value_to_crc32(value).
      # products = Product.search(:with => {:group_role => :child})
      # or
      # products = Product.search(:with => {:group_role => [:child, 'nothing']})
      # or
      # products = Product.search(
      #   :with => {:group_role => [:child, 'nothing']},
      #   :without => {:type => :ElectronicProduct}
      # )
      def convert_string_and_symbol_filter_values_to_crc32(option_hash)
        [:with, :without].each do |option|
          if option_hash.key?(option)
            option_hash[option].each do |filter, value|
              if value.instance_of?(Array)
                temp = []
                value.each do |v|
                  temp.push(filter_value_to_crc32(v))
                end
                value = temp
              else
                temp = filter_value_to_crc32(value)
              end
              option_hash[option][filter] = temp
            end
          end
        end
      end

      # This function converts a string or symbol value into a crc32 value
      # and returns it. Another value will be returned without convertion.
      def filter_value_to_crc32(value)
        if ['String', 'Symbol'].include?(value.class.name)
          value = value.to_s.to_crc32
        end
        return value
      end
    end
  end
end

module ActiveRecord
  class Base
    #Renews the index of the ActiveRecord model.
    def self.reindex(verbose = false)
      index_names = core_index_names + delta_index_names
      ret = ThinkingSphinx::Configuration.instance.controller.index(index_names)
      puts ret if verbose
    end
    
    def self.reindex_core(verbose = false)
      index_names = core_index_names
      ret = ThinkingSphinx::Configuration.instance.controller.index(index_names)
      puts ret if verbose
    end
    
    def self.reindex_delta(verbose = false)
      index_names = delta_index_names
      ret = ThinkingSphinx::Configuration.instance.controller.index(index_names)
      puts ret if verbose
    end
    
#    def self.reindex_all(verbose = false)
#      ThinkingSphinx.context.indexed_models.each do |model|
#        model.constantize.reindex(verbose)
#      end
#      nil
#    end
  end
end

module ThinkingSphinx
  module ActiveRecord
    module ClassMethods


    # from Riddle documentation:
    # Update attributes - first parameter is the relevant index, second is an
    # array of attributes to be updated, and the third is a hash, where the
    # keys are the document ids, and the values are arrays with the attribute
    # values - in the same order as the second parameter.


      def update_sphinx_attribute_values(objs, attribute_hash)
        return true unless ThinkingSphinx.updates_enabled? &&
          ThinkingSphinx.sphinx_running?

        objs = [objs] unless objs.class==Array

        # to update attributes of a sphinx document we should use its id
        # not the id of the model instance
        sphinx_document_ids = objs.collect{|o| o.sphinx_document_id}

        # collect keys to an array and convert them to strings from symbols
        attribute_names = attribute_hash.keys.collect{|k| k.to_s}
        attribute_values = attribute_hash.values

        values_by_doc = Hash.new
        sphinx_document_ids.each{|id|
          values_by_doc[id] = attribute_values
        }

#        p hash.inspect
#        return
        define_indexes

        config = ThinkingSphinx::Configuration.instance
        self.sphinx_indexes.each do |index|
          begin
            config.client.update index.core_name, attribute_names, values_by_doc
            next unless index.delta?
            config.client.update index.delta_name, attribute_names, values_by_doc
            #update_index index.delta_name, attribute_names, attribute_values
          rescue Riddle::ConnectionError, ThinkingSphinx::SphinxError => e
            Rails.logger.info e.message
            Rails.logger.info e.backtrace.inspect
          end
        end

        true
      end
    end
  end
end

module ThinkingSphinx
  module ActiveRecord
      def update_sphinx_attribute_values
        begin
          define_indexes
         
          update_attribute_values
        rescue Exception => e
          puts 'Exception by updating attribute values:'+e.inspect
        end
      end
  end
end


# temporaray debuging
module ThinkingSphinx
  module ActiveRecord
    module Delta
      def test_indexed_data_changed?
        indexed_data_changed?
      end
    end
  end
end


#Hook to parse right config file
ThinkingSphinx::Configuration.instance.reset(Rails.root) 