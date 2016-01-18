require 'fileutils'

module MonitConfigGenerator
  class Base
    def run 
      AppOnMongrelConfig.new.run
      WebistranoConfig.new.run
      SphinxSearchConfig.new.run
    end
  end
  
  class Config
    ENV_PATH = Rails.configuration.environment_base_path
    IP = '127.0.0.1'
    FILE_TYPE = 'set your file type here'

    def initialize
      @config = {:servers => 1, :port => 3000}
    end
    
    def run
      generate
    end
    
    def file_type
      self.class::FILE_TYPE
    end
    
    def user
      @user ||= ENV['USER']
    end

    private

    def generate
      puts "generate"
      @config[:servers].to_i.times do |idx|
        puts "server instance: #{idx}"
        port = @config[:port] + idx
        if config = generate_instance(idx, port)
          write(config, port)
        end
      end
    end

    def generate_instance(idx)
      raise
    end
    
    def make_dir(file_name)
      dir_name = File.dirname(file_name)
      FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)
    end
    
    def clean_up(config)
      config.gsub(/;\s;/, ';;').gsub(';;', ';')
    end
    
    def rails_root
      @rails_root ||= Rails.root.to_s.gsub(/\/releases\/.+$/, '/current')
    end

    def write(config, port)
      file_name = FileName.file_name(file_type, port)
      make_dir(file_name)
      File.open(file_name, 'w') do |f|
        f.write(clean_up(config))
      end
    end
  end
  
  class AppOnMongrelConfig < Config
    FILE_TYPE = 'application_mongrel'
    CONFIG_FILE = '*mongrel*.yml'

    def run
      if file_name = config_file
        load_config(file_name)
        generate
      else
        puts "There is no mongrel config file available."
      end
    end

    def load_config(file_name)
      parse(file_name)
    end

    def config_file
      Dir.glob(File.join(ENV_PATH, CONFIG_FILE)).first
    end

    private

    def parse(file_name)
      @config = YAML.load(File.open(file_name, 'r')).symbolize_keys
    end

    def generate_instance(idx, port)
      pid_file       = "#{rails_root}/tmp/pids/mongrel.#{port}.pid"
      log_file       = "#{rails_root}/log/mongrel.#{port}.log"
      #select_rvm_env = "source `which rvm`; rvm use ruby-1.8.7@rails238;"
      select_rvm_env = "#{RVMRC.parse(rails_root)};" #source `which rvm`; 
      
      make_dir(pid_file)
      make_dir(log_file)

      config = 
        "check process #{file_type}_#{port} with pidfile #{pid_file}\n" +
        "  group #{file_type}\n" +
        "  start program = \"/bin/su - #{user} -c '#{select_rvm_env}; rm #{pid_file}; cd #{rails_root}; mongrel_rails start -d -e #{Rails.env} -a #{IP} -c #{rails_root} -p #{port} -P #{pid_file} -l #{log_file}'\"\n" +
        "  stop program = \"/bin/su - #{user} -c '#{select_rvm_env}; cd #{rails_root}; mongrel_rails stop -P #{pid_file}'\"\n" +
        "\n" +
        "  if failed host #{IP} port #{port} protocol http\n" +
        "    with timeout 10 seconds for 5 cycles\n" +
        "    then restart\n" +
        "\n" +
        "  if totalmem > 150 Mb then restart\n" +
        "  if cpu is greater than 5% for 2 cycles then alert\n" +
        "  if cpu > 6% for 5 cycles then restart\n" +
        "  #if loadavg(5min) greater than 10 for 8 cycles then restart\n" +
        "  if 3 restarts within 5 cycles then timeout"
      
      return config
    end
  end
  
  class AppOnPumaConfig < Config
    FILE_TYPE = 'application_puma'
    CONFIG_FILE = 'puma.rb'

    def run
      if file_name = config_file
        load_config(file_name)
        generate
      else
        puts "There is no mongrel config file available."
      end
    end

    def load_config(file_name)
      parse(file_name)
    end

    def config_file
      Dir.glob(File.join(ENV_PATH, CONFIG_FILE)).first
    end

    private

    def parse(file_name)
      lines = File.open(file_name, 'r').readlines
      lines = lines.find_all{|l| !l.strip.start_with?('#') and !l.strip.blank?}
      lines = lines.map{|l| l.gsub("\n", '')}
      lines.each do |l|
        key, value = l.split(' ')
        @config[key.to_sym] = value.is_a?(String) ? value.gsub('"','').gsub("'",'') : value
      end
    end

    def generate_instance(idx, port)
      #"/home/gswww/sites/brunch_finden_de/releases/20130707161107"
      pid_file           = @config[:pidfile]
      config_file        = "#{rails_root}/config/environments/#{Rails.env}/puma.rb"
      #select_rvm_env     = "source `which rvm`; rvm use ruby-1.8.7@rails238;"
      select_rvm_env     = "#{RVMRC.parse(rails_root)}" #source `which rvm`; 
      start_puma_server  = "cd #{rails_root}; RAILS_ENV=#{Rails.env} puma -C #{config_file}"
      stop_puma_server   = "if [ -f #{pid_file} ]; then kill -s SIGTERM `cat #{pid_file}`; fi; rm #{pid_file}"
      delete_socket_file = ""
      
      make_dir(pid_file)
      
      bind = @config[:bind]
      supported_bind_types = ['tcp', 'unix']
      bind_parts = bind.split(':')
      port = nil
      socket_file = nil
      if supported_bind_types.include?(bind_parts.first)
        case bind_parts.first
        when 'tcp' then port = bind_parts.last
        when 'unix'
          socket_file = bind_parts.last.gsub(/\/\//,'')
          make_dir(socket_file)
          delete_socket_file = "rm #{delete_socket_file}"
        end
      else
        puts "#{bind_parts.first} isn't supported yet."
        return nil
      end
      puts bind

      config = 
        "check process #{file_type}_#{(port ? port : 'socket')} with pidfile #{pid_file}\n" +
        "  group #{file_type}\n" +
        "  start program = \"/bin/su - #{user} -c '#{stop_puma_server}; #{delete_socket_file}; #{select_rvm_env}; #{start_puma_server}'\"\n" +
        "  stop program = \"/bin/su - #{user} -c '#{stop_puma_server}'\"\n" +
        "\n" + 
        "#  if uptime > 24 hours then restart\n"
      if port
        config += "  if failed host #{IP} port #{port} protocol http " + 
                      "with timeout 10 seconds for 5 cycles " +
                      "then restart\n"
      elsif socket_file
        config += "  if failed unixsocket #{socket_file} then restart\n"
      end
      config += 
        "#  if totalmem > 405 Mb then restart\n" +
        "  if cpu is greater than 5% for 2 cycles then alert\n" +
        "  if cpu > 6% for 5 cycles then restart\n" +
        "  #if loadavg(5min) greater than 10 for 8 cycles then restart\n" +
        "  if 3 restarts within 5 cycles then timeout"
      
      return config
    end
  end
  
  class WebistranoConfig < Config
    FILE_TYPE = 'webistrano_rails_server'

    def initialize
      @config = {:servers => 1, :port => 3200}
    end
    
    private

    def generate_instance(idx, port)
      user = 'gsrepo'
      rails_root     = "/home/#{user}/sites/webistrano"
      pid_file       = "#{rails_root}/tmp/pids/webrick.#{port}.pid"
      #log_file       = "#{rails_root}/log/webrick.#{port}.log"
      select_rvm_env = "#{RVMRC.parse(rails_root)};" #source `which rvm`; 
      rails_server   = 'rails server'
      kill_process   = "if [ -f #{pid_file} ]; then kill -9 `cat #{pid_file}`; fi; rm #{pid_file};"
      
      make_dir(pid_file)
      
      config = 
        "check process #{file_type}_#{port} with pidfile #{pid_file}\n" +
        "  group #{file_type}\n" +
        "  start program = \"/bin/su - #{user} -c '#{kill_process}; #{select_rvm_env}; cd #{rails_root}; #{rails_server} -d -e #{Rails.env} -b #{IP} -p #{port} -P #{pid_file}'\"\n" +
        "  stop program  = \"/bin/su - #{user} -c '#{kill_process}'\"\n" +
        "\n" +
        "  if failed host #{IP} port #{port} protocol http\n" +
        "    with timeout 10 seconds for 5 cycles\n" +
        "    then restart\n" +
        "\n" +
        "  if totalmem > 150 Mb then restart\n" +
        "  if cpu is greater than 5% for 2 cycles then alert\n" +
        "  if cpu > 6% for 5 cycles then restart\n" +
        "  #if loadavg(5min) greater than 10 for 8 cycles then restart\n" +
        "  if 3 restarts within 5 cycles then timeout"
      
      return config
    end
  end
  
  class SphinxSearchConfig < Config
    FILE_TYPE = 'sphinxsearch'
    CONFIG_FILE = '*sphinx*.yml'

    def initialize
      @config = {:servers => 1, :port => 8000}
    end
    
    def run
      if file_name = config_file
        load_config(file_name)
        generate
      else
        puts "There is no sphinx config file available."
      end
    end

    def load_config(file_name)
      parse(file_name)
    end

    def config_file
      Dir.glob(File.join(ENV_PATH, CONFIG_FILE)).first
    end

    private

    def parse(file_name)
      @config = @config.merge(YAML.load(File.open(file_name, 'r')).symbolize_keys || {})
    end

    def generate_instance(idx, port)
      shared_dir     = rails_root.gsub('/current', '/shared')
      pid_file       = "#{shared_dir}/log/searchd.production.pid"
      config_file    = @config[:config_file]
      select_rvm_env = "#{RVMRC.parse(rails_root)}" #source `which rvm`; 
      start_process  = "searchd --pidfile --config #{config_file}"
      #kill_process   = "if [ -f #{pid_file} ]; then kill -9 `cat #{pid_file}`; fi; /bin/rm #{pid_file}"
      kill_process   = "#{start_process} --stop"
      
      make_dir(pid_file)
      
      config = 
        "check process #{file_type}_#{port} with pidfile #{pid_file}\n" + 
        "  group #{file_type}\n" +
        "  #start program = \"/bin/su - #{user} -c '#{kill_process}; #{select_rvm_env}; cd #{rails_root}; RAILS_ENV=#{Rails.env} rake ts:config; RAILS_ENV=#{Rails.env} rake ts:start'\"\n" +
        "  #stop program = \"/bin/su - #{user} -c '#{kill_process}; #{select_rvm_env}; cd #{rails_root}; RAILS_ENV=#{Rails.env} rake ts:config; RAILS_ENV=#{Rails.env} rake ts:stop'\"\n" +
        "  start program = \"/bin/su - #{user} -c '#{start_process}'\"\n" + 
        "  stop program = \"/bin/su - #{user} -c '#{kill_process}; sleep 1'\"\n" + 
        "\n" +
        "  if failed port #{port}\n" + 
        "    with timeout 15 seconds for 2 cycles\n" +
        "    then restart\n" +
        "  if totalmem > 150 Mb then restart\n" + 
        "  if 3 restarts within 5 cycles then timeout"
      
      return config
    end
  end

  class FileName
    MONIT_CONFIG_PATH = "#{ENV['HOME']}/configs/monit"

    def self.base_name(file_type, port)
      "#{file_type}_#{port}.conf"
    end

    def self.file_name(file_type, port)
      "#{path}/#{base_name(file_type, port)}"
    end

    def self.path
      MONIT_CONFIG_PATH
    end
  end
  
  class RVMRC
    def self.parse(path)
      ret = ''
      lines = File.open("#{path}/.rvmrc", 'r').readlines
      lines.each do |line|
        if line.start_with?('rvm use')
          ret = line.gsub("\n", '')
          break
        end
      end
      return ret
    end
  end
end
