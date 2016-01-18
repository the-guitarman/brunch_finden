# This script is used with the webistrano task 'fill up custom and
# background configs' and it copies all files and directories
# from current/config/custom and current/config/background to
# shared/config_custom and shared/config_background, if the destination
# directories are empty only.

# This is importend to be able to start the application mongrel servers after
# the first deploy and to have a first changable stage configuration.

require 'fileutils'

current_path = ARGV[0].to_s
shared_path  = ARGV[1].to_s

paths = {
  'config/custom_templates'     => 'config_custom',
  'config/background_templates' => 'config_background',
}

paths.each do |source, destination|
  destination_files = Dir.glob("#{shared_path}/#{destination}/**/*.*")
  if destination_files.empty?
    puts 'Copy Custom And Background Configurations:'
    stage_directories = Dir.entries("#{current_path}/#{source}/")
    stage_directories.delete_if {|x| x == '.' or x == '..' or x == '.svn' or x.downcase == 'readme'}

    stage_directories.each do |stage_directory|
      source_stage_directory = "#{current_path}/#{source}/#{stage_directory}"
      if File.directory?(source_stage_directory)
        destination_stage_directory = "#{shared_path}/#{destination}/#{stage_directory}"
        source_files = Dir.glob("#{source_stage_directory}/**/*.*")
        source_files.each do |source_file|
          source_dir = File.dirname(source_file)
          sub_directory = source_dir.gsub(source_stage_directory, '')
          destination_file = "#{destination_stage_directory}#{sub_directory}/#{File.basename(source_file)}"
          puts "copy: #{source_file} -> #{destination_file}"
          FileUtils.mkdir_p("#{destination_stage_directory}#{sub_directory}")
          FileUtils.copy_file(source_file, destination_file)
        end
      end
    end
  else
    puts "Configurations in #{shared_path}/#{destination}) exist. Nothing to do!"
  end
end