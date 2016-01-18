module ActiveRecord
  ver = Rails::VERSION

  class Base 
    def preserve_changes
      @changes = self.changes
    end
  
    # ActiveRecord::Base.check_for_model_class?(Product)     # => true
    # ActiveRecord::Base.check_for_model_class?("Product")   # => true
    # ActiveRecord::Base.check_for_model_class?(:Product)    # => true
    # ActiveRecord::Base.check_for_model_class?("Products")  # => false
    def self.check_for_model_class?(class_name_or_class)
      connection = ActiveRecord::Base.connection
      if not defined?(@@application_models) or @@application_models.length < connection.tables.length
        # not all model classes are loaded
        #@@application_models = ActiveRecord::Base.descendants.map{|klass| klass.name}
        @@application_models = []
        connection.tables.each do |table_name|
          @@application_models.push(table_name.singularize.camelize)
        end
      end
      class_name = if class_name_or_class.instance_of?(String)
        class_name_or_class
      elsif class_name_or_class.instance_of?(Symbol)
        class_name_or_class.to_s
      elsif class_name_or_class.instance_of?(Class)
        class_name_or_class.name
      end
      if class_name.blank?
        return false
      else
        @@application_models.include?(class_name)
      end
    end
    
    def self.model_config(*keys)
      raise 'No keys given to read from model configuration.' if keys.empty?

      model_config = BackgroundConfigHandler.instance.model_config
      model_name = keys.delete_at(0)
      unless model_config.has_key?(model_name)
        raise "No model configuration found for #{model_name}."
      end

      result = model_config[model_name]
      steps = "[#{model_name}]"
      while not keys.empty?
        key = keys.delete_at(0)
        steps += "[#{key}]"
        if result.has_key?(key)
          result = result[key]
        else
          raise "Key not found in model configuration: #{steps}."
        end
      end
      return result
    end
  end
  
  module ConnectionAdapters
    class MysqlAdapter
      def move_column(table_name, column_name, type, options = {})
        raise 'Use first or after option instead of before.' if options[:before]
        raise 'First or after option needed.' unless (options[:first] or options[:after])
        if index_exists = index_exists?(table_name, column_name, nil)
          remove_index table_name, column_name
        end
        temp_column_name = "#{column_name}_new".to_sym
        add_column table_name, temp_column_name, type, options
        execute("UPDATE #{table_name} SET #{temp_column_name} = #{column_name}")
        remove_column table_name, column_name
        rename_column  table_name, temp_column_name, column_name
        if index_exists
          add_index table_name, column_name
        end
      end
    end
    
    class Mysql2Adapter
      def move_column(table_name, column_name, type, options = {})
        raise 'Use first or after option instead of before.' if options[:before]
        raise 'First or after option needed.' unless (options[:first] or options[:after])
        if index_exists = index_exists?(table_name, column_name, options)
          remove_index table_name, column_name
        end
        temp_column_name = "#{column_name}_new".to_sym
        add_column table_name, temp_column_name, type, options
        execute("UPDATE #{table_name} SET #{temp_column_name} = #{column_name}")
        remove_column table_name, column_name
        rename_column  table_name, temp_column_name, column_name
        if index_exists
          add_index table_name, column_name
        end
      end
    end
  end

  # extend rails 2.3.5 modules with 2.3.8 methods
  if ver::MAJOR <= 2 and ver::MINOR <= 3 and ver::TINY <= 5
    module ConnectionAdapters
      module SchemaStatements
        # Check whether or not an index exists on the table.
        # This method exists (http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#M001473).
        # But how to use?
        def index_exists?(table_name, index_name, default)
          return default unless respond_to?(:indexes)
          indexes(table_name).detect { |i| i.name == index_name }
        end
      end
    end

    module ConnectionAdapters
      module PostgreSQLAdapter
        def indexes(table_name, name = nil)
          schemas = schema_search_path.split(/,/).map { |p| quote(p) }.join(',')
          result = query("SELECT distinct i.relname, d.indisunique, d.indkey, t.oid\nFROM pg_class t, pg_class i, pg_index d\nWHERE i.relkind = 'i'\nAND d.indexrelid = i.oid\nAND d.indisprimary = 'f'\nAND t.oid = d.indrelid\nAND t.relname = '\#{table_name}'\nAND i.relnamespace IN (SELECT oid FROM pg_namespace WHERE nspname IN (\#{schemas}) )\nORDER BY i.relname\n", name)


          indexes = []

          indexes = result.map do |row|
            index_name = row[0]
            unique = row[1] == 't'
            indkey = row[2].split(" ")
            oid = row[3]

            columns = query("SELECT a.attname, a.attnum\nFROM pg_attribute a\nWHERE a.attrelid = \#{oid}\nAND a.attnum IN (\#{indkey.join(\",\")})\n", "Columns for index #{row[0]} on #{table_name}").inject({}) {|attlist, r| attlist[r[1]] = r[0]; attlist}

            column_names = indkey.map {|attnum| columns[attnum] }
            IndexDefinition.new(table_name, index_name, unique, column_names)

          end

          indexes
        end
      end
    end
  end
end

class Object
  def self.is_model_class?
    ActiveRecord::Base.check_for_model_class?(self)
  end
  
  def has_model_class?
    unless self.is_a?(Class)
      self.class.is_model_class?
    else
      self.is_model_class?
    end
  end
end