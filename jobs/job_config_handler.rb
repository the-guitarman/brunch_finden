# Include this module to your class to save thrown exceptions into a 
# config file of the class and send an error email. 
# Call the instance method exception_thrown(e) to do so, where the 
# parameter e is the thrown exception.
# 
# In case of no exception (all thing are well done) call the instance
# method reset_config to save the initial values the config.
# 
# It needs two instance variables to be defined in the class, 
# which includes this module:
# * @config_handler
# ** for example: @config_handler = CustomConfigHandler.instance
# * @config_handler_method
# ** for example: @config_handler_method = :coupon_fetcher_config
module JobConfigHandler
  def self.included(klass)
    klass.instance_eval do
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    attr_accessor :config, :config_handler, :config_handler_method
    
    private

    def exception_thrown(e, msg = '')
      error = "@uri: #{@uri}\n\n#{e.message}\n\n#{e.backtrace.join("\n")}\n\n"
      error += "#{msg}\n\n" unless msg.blank?
      load_config
      if @config['ERROR_COUNTER'] <= 10
        @config['ERROR_COUNTER'] += 1
        @config['LAST_ERROR'] = Time.now.to_s(:db)
        @config['ERRORS'] = {} unless @config['ERRORS'].is_a?(Hash)
        @config['ERRORS'][@config['ERROR_COUNTER']] = error
        if @config['ERROR_COUNTER'] == 1
          Mailers::AdminMailer.deliver_report_error(error)
        end
      end
      write_config
    end

    def load_config
      default = {'ERRORS' => nil, 'ERROR_COUNTER' => 0}
      @config = (eval("@config_handler.#{@config_handler_method}(true)") || default rescue default)
    end

    def write_config
      eval("
        unless File.exist?(@config_handler.#{@config_handler_method}_file)
          File.open(@config_handler.#{@config_handler_method}_file, 'a') do |f|
            f.write('')
          end
        end
        @config_handler.write_#{@config_handler_method}(@config)
      ")
    end

    def reset_config
      load_config
      @config['ERROR_COUNTER'] = 0
      @config['ERRORS'] = {}
      @config['LAST_RESET'] = Time.now.to_s(:db)
      write_config
    end
  end
end