module SearchQuery
  SEARCH_QUERY_LOG = 'log/search_queries_log.txt'
  
  module Logger
    def self.included(klass)
      klass.instance_eval do
        #extend ClassMethods
        include InstanceMethods
      end
    end

    module InstanceMethods
      def log_search_query(search_type, query)
        @@search_query_logger ||= ::Logger.new("#{Rails.root}/#{SEARCH_QUERY_LOG}")
        @@search_query_logger.info("#{Time.now.to_s(:db)}, #{search_type}: #{query}")
      end
    end

    #module ClassMethods
    #  
    #end
  end
  
  module Reporter
    def self.included(klass)
      klass.instance_eval do
        #extend ClassMethods
        include InstanceMethods
      end
    end

    module InstanceMethods
      def report
        file_name = "#{Rails.root}/#{SEARCH_QUERY_LOG}"
        
        msg = ''
        if File.exist?(file_name) and File.size(file_name) > 0
          File.open(file_name, 'r') do |f|
            while f.eof == false
              line = f.readline.to_s.strip
              unless line.start_with?('#')
                msg += "#{line}\n"
              end
            end
          end
        end
        
        File.open(file_name, 'w') do |f|
          f.write("# Log file truncated at #{Time.now.to_s(:db)}.")
        end
        
        if msg.blank?
          msg += I18n.t('shared.search.reporter.no_searches')
            #'There are not search queries to report.'
        end
        
        Mailers::AdminMailer.deliver_report_search_queries(msg)
      end
    end

    #module ClassMethods
    #  
    #end
  end
end