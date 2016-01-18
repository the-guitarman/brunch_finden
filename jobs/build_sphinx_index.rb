class BuildSphinxIndex
  include Singleton
  
  #SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST WHERE command <> 'sleep' AND time > 10 ORDER BY time DESC;
  
  # klass_name may be an active record class or a name (string or symbol) 
  # which can be converted into an active record class. In addition it can 
  # hold an options hash. 
  # The :index option defines what's to index (:core or :delta). :core includes 
  # :delta as well. :index defaults to :core.
  # The :offset option lets you define at which table_name.id you want to start to 
  # reset the deltas.
  def run(*klass_names)
    options = klass_names.extract_options!
    @index  = options.delete(:index) || :core
    @offset = options.delete(:offset).to_i if klass_names.length == 1
    @limit= options.delete(:limit) || 1000
    klass_names.each do |klass_name|
      index_klass(klass_name)
    end
  end

  def run_reset_deltas(klass,limit=1000,offset=0)
    @offset = offset
    @limit= limit
    reset_deltas(klass)
  end
  
  def deltas(*klass_names)
    klass_names.each do |klass_name|
      count_deltas(klass_name)
    end
  end
  
  def count(*klass_names)
    klass_names.each do |klass_name|
      count_all(klass_name)
    end
  end
  
  def percentage(*klass_names)
    klass_names.each do |klass_name|
      deltas_in_percent(get_klass(klass_name))
    end
  end
  
  private
  
  def count_all(klass_name)
    klass = get_klass(klass_name)
    return unless klass_defines_indexes?(klass)
    query  = "SELECT count(#{quoted_column_name(klass, 'id')}) FROM #{klass.quoted_table_name};"
    number = indexer_database_connection.select_value(query)
    puts "Records in #{klass.table_name}: #{number}"
    return number
  end
  
  def count_deltas(klass_name)
    klass = get_klass(klass_name)
    return unless klass_defines_indexes?(klass)
    query  = "SELECT count(#{quoted_column_name(klass, 'id')}) FROM #{klass.quoted_table_name} WHERE #{quoted_delta_column_name(klass)} > 0;"
    number = indexer_database_connection.select_value(query)
    puts "Deltas in #{klass.table_name}: #{number}"
    return number
  end
  
  def index_klass(klass_name)
    klass = get_klass(klass_name)
    return unless klass_defines_indexes?(klass)
    if index_core?(klass)
      reset_deltas(klass)
      wait_for_indexer_database_has_finished_deltas_reset
      index_core(klass)
      index_delta(klass)
    else 
      index_delta(klass)
    end
    puts ""
  rescue Exception => e
    puts "klass name: #{klass_name}\n\nmessage: #{e.message}\n\nbacktrace: #{e.backtrace.join("\n")}"
  end
  
  def index_core?(klass)
    ret = @index == :core
    puts "Index #{ret ? ':core and ' : ''}:delta for #{klass.name}"
    return ret
  end
  
  def index_core(klass)
    klass.reindex_core(true)
  end
  
  def index_delta(klass)
    return unless klass_defines_delta_indexes?(klass)
    klass.reindex_delta(true)
  end
  
  def get_klass(klass_name)
    ret = klass_name
    if klass_name.is_a?(String) or klass_name.is_a?(Symbol)
      ret = klass_name.to_s.downcase.camelize.constantize
    end
    return ret
  end
  
  def klass_defines_indexes?(klass)
    ret = false
    if klass.respond_to?(:define_indexes) and klass.respond_to?(:indexed_by_sphinx?)
      klass.define_indexes
      ret = !!klass.indexed_by_sphinx?
    end
    puts "WARNING: #{klass.name} defines no indexes." unless ret
    return ret
  end
  
  def klass_defines_delta_indexes?(klass)
    column =  klass.columns.find{|c| c.name == delta_column_name}
    ret = column && klass.delta_indexed_by_sphinx?
    puts "WARNING: #{klass.name} defines no delta indexes." unless ret
    return ret
  end
  
  def delta_column_name
    return 'delta'
  end
  
  def quoted_column_name(klass, column_name)
    return klass.connection.quote_column_name(column_name)
  end
  
  def quoted_delta_column_name(klass)
    return quoted_column_name(klass, delta_column_name)
  end
  
  def reset_deltas(klass)
    return unless klass_defines_delta_indexes?(klass)
    
    percent = deltas_in_percent(klass)
    
    puts "Reseting deltas for #{klass.name} ... "
    
    updates_total = 0
    offset = @offset || 0
    limit  = @limit || delta_reset_limit(klass, percent)
    max_klass_id = indexer_database_connection.select_value("SELECT MAX(#{quoted_column_name(klass, 'id')}) FROM #{klass.quoted_table_name};").to_i
    puts "max id (#{klass.table_name}): #{max_klass_id}"
    
    while offset < max_klass_id do 
      updates = 0
      time = Benchmark.realtime do
        updates = klass.connection.update_sql(reset_deltas_query(klass, offset, limit))
      end
      updates_total += updates
      query_time = sprintf("%#.1f", (time * 1000).to_s).to_f
      sleep_time = reset_deltas_sleep_time(query_time)
      puts "query time:#{query_time.to_s.ljust(10)}ms - " +
           "updates:#{updates.to_s.ljust(4)} - " +
           "query:#{@query} - " +
           "sleep_time:(#{sprintf("%#.3f", sleep_time.to_s)})"
      sleep(sleep_time)
      offset += limit
    end
    
#    resets = klass.connection.update_sql(reset_deltas_query(klass))
    puts "Reseting deltas for #{klass.name} done! (deltas updated: #{updates_total})"
  end
  
  def reset_deltas_sleep_time(query_time)
    sleep_time = (query_time / 1000) / 2
    sleep_time = 3 if sleep_time > 3
    return sleep_time
  end
  
  def deltas_in_percent(klass)
    number_all = count_all(klass.name.underscore).to_i
    number_deltas = count_deltas(klass.name.underscore).to_i
    percent = sprintf("%#.2f", (number_deltas.to_f / number_all * 100).to_s).to_f
    puts "Deltas in #{klass.table_name}: #{percent} %"
    return percent
  end
  
  def delta_reset_limit(klass, percent)
    if percent > 20
      limit = 500
    else
      limit = 1000
    end
    puts "Reset deltas limit for #{klass.table_name} set to: #{limit}"
    return limit
  end
  
#  def reset_deltas_query(klass)
#    column = quoted_delta_column_name(klass)
#    return "UPDATE #{klass.quoted_table_name} SET #{column} = 0 WHERE #{column} > 0"
#  end
  
  def reset_deltas_query(klass, offset, limit)
    column = quoted_delta_column_name(klass)
    id_quoted = quoted_column_name(klass, 'id')
    @query = "UPDATE LOW_PRIORITY #{klass.quoted_table_name} SET #{column} = 0 WHERE #{id_quoted} >= #{offset} and #{id_quoted} < #{offset + limit} AND #{column} > 0"
    return @query
  end
  
  def wait_for_indexer_database_has_finished_deltas_reset
    print "Waiting for query to finish deltas reset ..."
    time = Benchmark.realtime do
      sleep 1; print '.'
      while deltas_reset_query_runs_at_indexer_database?
        sleep 5; print '.'
      end
    end
    puts "done! (time: #{time.ceil} sec)"
  end
  
  def deltas_reset_query_runs_at_indexer_database?
    query_ids = []
    unless @query.blank?
      sql = 'SELECT id FROM INFORMATION_SCHEMA.PROCESSLIST ' + 
            "WHERE command = 'Query' AND info = '#{@query}';"
      query_ids = indexer_database_connection.select_values(sql)
      #puts "Query ids found: #{query_ids.inspect}"
    end
    return !query_ids.empty?
  end
  
  def indexer_database_connection
    unless @conn
      pool = ActiveRecord::Base.establish_connection(:indexer_database)
      @conn = pool.connection
    end
    return @conn
  end
end
