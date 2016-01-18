USER = 'sebastian'
RAILS_ROOT = File.expand_path("#{File.expand_path("..",__FILE__)}/../../..")
RAILS_ENV = ENV['RAILS_ENV'] || 'production_dev'

working_directory RAILS_ROOT
pid RAILS_ROOT + "/tmp/pids/unicorn.pid"
stderr_path RAILS_ROOT + "/log/unicorn.error.log"
stdout_path RAILS_ROOT + "/log/unicorn.out.log"

p addr="127.0.0.1:3000"
listen addr
#listen RAILS_ROOT + '/tmp/sockets/unicorn.sock', :backlog => 64
worker_processes 4
#preload_app false
#timeout 60

#before_fork do |server, worker|
#  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
#  
#  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
#  # immediately start loading up a new version of itself (loaded with a new
#  # version of our app). When this new Unicorn is completely loaded
#  # it will begin spawning workers. The first worker spawned will check to
#  # see if an .oldbin pidfile exists. If so, this means we've just booted up
#  # a new Unicorn and need to tell the old one that it can now die. To do so
#  # we send it a QUIT.
#  #
#  # Using this method we get 0 downtime deploys.
#  old_pid = RAILS_ROOT + '/tmp/pids/unicorn.pid.oldbin'
#  if File.exists?(old_pid) && server.pid != old_pid
#    begin
#      Process.kill("QUIT", File.read(old_pid).to_i)
#    rescue Errno::ENOENT, Errno::ESRCH
#      # someone else did our job for us
#    end
#  end
#end

#after_fork do |server, worker|
#  addr = "127.0.0.1:#{3000 + worker.nr}"
#  server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)
#
#  # Unicorn master loads the app then forks off workers - because of the way
#  # Unix forking works, we need to make sure we aren't using any of the parent's
#  # sockets, e.g. db connection
#
#  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
#
#  # Redis and Memcached would go here but their connections are established
#  # on demand, so the master never opens a socket
#
#
#
#  # Unicorn master is started as root, which is fine, but let's
#  # drop the workers to sebastian:sebastian
#
#  begin
#    uid, gid = Process.euid, Process.egid
#    user, group = USER, USER
#    target_uid = Etc.getpwnam(user).uid
#    target_gid = Etc.getgrnam(group).gid
#    worker.tmp.chown(target_uid, target_gid)
#    if uid != target_uid || gid != target_gid
#      Process.initgroups(user, target_gid)
#      Process::GID.change_privilege(target_gid)
#      Process::UID.change_privilege(target_uid)
#    end
#  rescue => e
#    if RAILS_ENV == 'development'
#      STDERR.puts "couldn't change user, oh well"
#    else
#      raise e
#    end
#  end
#end

#working_directory app_path="#{File.expand_path("..",__FILE__)}/../../.."
#pid app_path+"/log/rainbows.pid"
#stderr_path app_path+"/log/unicorn.error.log"
#stdout_path app_path+"/log/unicorn.out.log"
#p addr="#{`ifconfig eth0`.scan(/inet (addr|Adresse):([0-9.]+)\s.*/).flatten[1]}:3200"
#listen addr
#worker_processes 20# assuming 8 CPU cores
#timeout 60
##Rainbows! do
##  use :Coolio
##  use :FiberSpawn
##  worker_connections 10
##end
