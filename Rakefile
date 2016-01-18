# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# Bootstrap the Rails environment, frameworks, and default configuration
require(File.join(File.dirname(__FILE__), 'config', 'boot'))

# Load postboot file to change Rails paths
require File.join(File.dirname(__FILE__), 'config', 'postboot')

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
#require 'rdoc/task'

require 'tasks/rails'

begin
  require 'thinking_sphinx/tasks'
rescue LoadError
  puts "You can't load Thinking Sphinx tasks unless the thinking-sphinx gem is installed."
end

