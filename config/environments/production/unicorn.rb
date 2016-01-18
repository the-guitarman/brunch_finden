RAILS_ENV = ENV['RAILS_ENV'] || 'production'
RAILS_ROOT = "#{File.expand_path("..",__FILE__)}/../../../"

#p addr = '127.0.0.1:3000'
#listen addr
p socket = RAILS_ROOT + '/tmp/sockets/puma.sock'
listen socket, :backlog => 64
worker_processes 2

pid RAILS_ROOT + '/tmp/pids/unicorn.pid'
stderr_path RAILS_ROOT + '/log/unicorn.error.log'
stdout_path RAILS_ROOT + '/log/unicorn.out.log'

timeout 60
 
preload_app true
 
before_fork do |server, worker|
  # stops old master
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end
 
after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end