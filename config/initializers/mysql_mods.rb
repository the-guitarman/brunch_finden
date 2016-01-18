require 'rubygems'
#gem 'oldmoe-mysqlplus'
#MYSQLPLUS STUFF:
## require 'mysqlplus'

## class Mysql
##   alias_method :query, :c_async_query
## end

module ActiveRecord::ConnectionAdapters
  class MysqlAdapter
    alias_method :execute_without_retry, :execute
    def execute(*args)
      execute_without_retry(*args)
    rescue ActiveRecord::StatementInvalid
      if $!.message =~ /server has gone away/i
        warn "Server timed out, retrying"
        reconnect!
        retry
      end

      raise
    end
  end
end

class ActiveRecord::ConnectionAdapters::ConnectionHandler
  alias old_retrieve_connection retrieve_connection
  def retrieve_connection(klass)
    old_retrieve_connection(klass)
  rescue ActiveRecord::ConnectionNotEstablished
    warn "ConnectionError no Connection found, retry"
    klass.verify_active_connections!
    sleep 1
    old_retrieve_connection(klass)
  end
end