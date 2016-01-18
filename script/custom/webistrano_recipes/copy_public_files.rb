# copy all public files in shared (e.g. google*.html)
# into the public of the current stage

require 'fileutils'

current_path = ARGV[0].to_s
shared_path  = ARGV[1].to_s

source_directory = "#{shared_path}/public"
destination_directory = "#{current_path}/public/"

unless File.directory?(source_directory)
  #run "mkdir -p #{shared_path}/public"
  Dir.mkdir(source_directory)
else
  public_entries = Dir.entries(source_directory).delete_if {|x| x == '.' or x == '..' or x == '.svn'}
  unless public_entries.empty?
    #run "cp -frv #{shared_path}/public/* #{current_path}/public/"
    source_files = Dir.glob("#{source_directory}/**/*")
    source_files.each do |source_file|
      source_dir = File.dirname(source_file)
      sub_directory = source_dir.gsub(source_directory, '')
      destination_file = "#{destination_directory}#{sub_directory}/#{File.basename(source_file)}"
      puts "copy: #{source_file} -> #{destination_file}"
      FileUtils.mkdir_p("#{destination_directory}#{sub_directory}")
      FileUtils.copy_file(source_file, destination_file)
    end
  end
end