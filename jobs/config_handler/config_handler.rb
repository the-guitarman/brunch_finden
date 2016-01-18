#encoding: UTF-8
$KCODE = 'UTF8' unless RUBY_VERSION >= '1.9'
require 'ya2yaml'

module ConfigHandler
  def self.included(klass)
    klass.instance_eval do
      include Singleton
  
      extend ClassMethods
      include InstanceMethods
    end
  end
  
  module ClassMethods
    def acts_as_config_handler(cfp = '', cf = {}, gcf = {})
      cattr_accessor :files_path, :config_files, :global_config_files
      
      # initialize class variables
      self.files_path = cfp
      self.config_files = cf
      self.global_config_files = gcf
      
      define_method_proc = Proc.new do |path, config_file, extension|
        class_eval("
          def #{config_file}(reload = false)
            if reload or @#{config_file}.blank?
              @#{config_file} = load_config('#{path}#{config_file}.#{extension}', :#{extension})
            end
            return deep_copy(@#{config_file})
          end
          
          def write_#{config_file}(data)
            write_config('#{config_file}', data)
          end
          
          def #{config_file}_file
            '#{path}#{config_file}.#{extension}'
          end
        ")
      end

      config_files.each do |config_file, extension|
        define_method_proc.call(files_path, config_file, extension)
      end

      path = files_path.gsub(/#{Rails.env}\/$/, '')
      global_config_files.each do |global_config_file, extension|
        define_method_proc.call(path, global_config_file, extension)
      end
    end
  end
  
  module InstanceMethods
    def reload!
      load_all_configs(true)
    end
    alias reload reload!

    # loads link listst from yaml_file after the server start
    def configure
      load_all_configs    
    end

    private

    def load_all_configs(reload = false)
      config_files.each do |config_file, extension|
        basename = File.basename(config_file, extension.to_s)
        eval("#{basename}(reload)")
      end
      global_config_files.each do |config_file, extension|
        basename = File.basename(config_file, extension.to_s)
        eval("#{basename}(reload)")
      end
      return true
    end

    # @return content of YAML File file 
    # file must include the path to the file
    # used in *_config methods to load config
    def load_config(file, extension)
      ret = nil
      if File.exist?(file)
      ret = File.open(file, 'r').read
      if extension == :yml
        ret = YAML::load(ret) 
      elsif extension == :txt
        ret = File.open(file, 'r').read
      end
      end
      return ret
    end

    def deep_copy(obj)
      return Marshal.load(Marshal.dump(obj))
    end

    def write_config(method_name, data)
      file = files_path
      extension = config_files[method_name.to_sym]
      if global_config_files.keys.include?(method_name.to_sym)
        file.gsub!(/#{Rails.env}\/$/, '')
        extension = global_config_files[method_name.to_sym]
      end
      file += "#{method_name}.#{extension}"
      
      #puts "_data: #{data.inspect}"
      #puts "_data: #{file}"

      # read lines and extract comment lines
      comments = []
      if File.exist?(file)
        File.open(file, 'r') do |f|
        comments = f.readlines
      end
      comments.delete_if{|l| !l.start_with?('#')}
      end

      # save comments and new config
      File.open(file, 'w') do |f|
        f.puts comments.join + data.to_yaml
      end
    end
  end
end
