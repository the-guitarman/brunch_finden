# Be sure to restart your server when you modify this file.


rails_env = ENV['RAILS_ENV'] || 'development'

env_dir  = File.join(Rails.root.to_s, 'config/environments/', rails_env)
db_file  = File.join(env_dir, 'database.yml')
env_file = File.join(env_dir, 'environment.rb')

unless File.exists?(env_dir)
  puts "#{env_dir} environment directory cannot be found."
  exit(1)
end

unless File.exists?(db_file)
	puts "#{db_file} is missing.  You cannot continue without this."
	exit(1) # exit with an error code
end

unless File.exists?(env_file)
  puts "#{env_file} environment file is missing." 
  exit(1)
end

# Now, let's open up Rails and tell it to find our environment files elsewhere.
module Rails
  class Configuration

    def environment_base_path
      "#{root_path}/config/environments/#{environment}"
    end

    def database_configuration_file
      File.join(environment_base_path, 'database.yml')
    end
    
    # The path to the current environment's file (development.rb, etc.). By
    # default the file is at <tt>config/environments/#{environment}.rb</tt>.
    def environment_path
      "#{environment_base_path}/environment.rb"
    end
  end
end
