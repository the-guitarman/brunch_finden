#/usr/bin/rvm use default
require 'optparse'

module ConfigFile
  def self.read
    $server_file=File.open($server_file_name,'r').readlines
  end

  def self.find_opt(identifier)
    option=nil
    $server_file.each do |l| 
      if l.=~ /^#-?#{identifier}:/
        option=l.split(":")[1].strip
      end
    end
    option
  end

  def self.get_section(identifier)
    section=[]
    in_section=false
    $server_file.each do |l|
      if l.=~ /^#-?#{identifier}\s/
        in_section=true
      end
      if in_section
        if l.start_with?("#END")
          in_section=false
        else
          section.push l unless l.empty? or l.start_with?("#")
        end
      end
    end
    section
  end

  #removes config parameters from server config file
  def self.get_clean_file
    file=[]
    $server_file.each do |l|
      unless l.start_with?("#-")
        file.push l
      end
    end
    file
  end
end

module Host
  def self.set_local_host
    ifc=`/sbin/ifconfig`
    ext_servers=ConfigFile.get_section("SERVER")
    ext_servers.each do |l|
      parts=l.split
      if ifc.include?(parts.first.strip)
        $local_ext_ip=parts.first.strip
        $local_host_name=parts.last.split("_").first.strip
      end
    end
  end
  def self.get_ip(host,suffix="")
    ip=nil
    suffix="_"+suffix unless suffix.empty?
    $server_file.each do |l|
      if l.include? host+suffix
        ip=l.split.first.strip
      end
    end
    ip
  end
  def self.ext_ip(host)
    get_ip(host,"ext")
  end
  def self.vpn_ip(host)
    get_ip(host,"vpn")
  end
  def self.int_ip(host)
    get_ip(host,"int")
  end
end

class SystemConfigFile
  def initialize(file_name)
    @file_name=file_name
  end
  #param: from_line - if this line is included in file, content will be append
  #starting on this line. Everything beneath this line will be deleted
  def append(content,from_line)
    print "Update #{@file_name}..\n"
    original_lines=[]
    File.open(@file_name,"r") do |f|
      server_def_found=false
      while not server_def_found and not f.eof
        line=f.readline 
        if line.include?(from_line)
          server_def_found=true
        else
          original_lines.push line
        end
      end
    end
    File.open(@file_name,'w').write((original_lines+content).join) 
  end
end

#module VPN
  #BASE_DIR="/etc/n2n"
  #def self.write_config
    #print "Configure VPN..\n"
    #self.get_vpn_data
    #Dir.mkdir(BASE_DIR) unless File.exist?(BASE_DIR)
    #self.write_edge_config
    #if @@dispatcher==$local_host_name
      #self.write_supernode_config
    #end
    #self.write_vpn_init_script
  #end

  #def self.generate_mac
    #numbers=@@local_vpn_ip.split(".")
    #hex_numbers=numbers.map {|n| m=n.to_i.to_s(16);m.length<2?"0"+m : m} #base 16 number
    #mac="00:00:"+hex_numbers.join(":")
  #end

  #def self.write_edge_config
    #key_file_name="/etc/n2n/key"
    #File.open(key_file_name,"w") do |f|
      #f.puts(@@password)
      #f.chmod(0600)
    #end
    #File.open(BASE_DIR+"/edge.sh","w") do |f|
      #f.puts("#!/bin/sh")
      #f.puts("cat #{key_file_name}| xargs edge -f -a #{@@local_vpn_ip} -m #{VPN.generate_mac} "+
             #"-c #{@@community} -l #{Host.ext_ip(@@dispatcher)}:6000 -k ")
      #f.chmod(0700)
    #end
  #end

  #def self.write_supernode_config
    #File.open(BASE_DIR+"/supernode.sh","w") do |f|
      #f.puts("#!/bin/sh\n")
      #f.puts("supernode -l 6000")
      #f.chmod(0700)
    #end
  #end

  #def self.write_vpn_init_script
    #init_file_name="/etc/init.d/n2n"
    #File.open(init_file_name,"w") do |f|
      #f.puts("#!/bin/sh")
      #f.puts("/etc/n2n/edge.sh &")
      #f.puts("/etc/n2n/supernode.sh &") if File.exist? "/etc/n2n/supernode.sh"
      #f.chmod(0755)
    #end
    #`update-rc.d n2n defaults`
    #puts "  *** To start VPN call /etc/init.d/n2n or reboot this machine. ***"
  #end

  #def self.get_vpn_data
    #@@dispatcher=ConfigFile.find_opt("VPN_DISPATCHER")
    #@@community=ConfigFile.find_opt("VPN_NAME")
    #@@password=ConfigFile.find_opt("VPN_PWD")
    #@@local_vpn_ip=Host.vpn_ip($local_host_name)
    #print "  Configure with net #{@@community} by #{@@dispatcher}.\n"
  #end

#end

module Services
  @@apache_modules=%w(alias.conf alias.load auth_basic.load authn_file.load authz_default.load authz_groupfile.load authz_host.load
    authz_user.load autoindex.conf autoindex.load cgi.load deflate.conf deflate.load dir.conf dir.load env.load headers.load
    mime.conf mime.load negotiation.conf negotiation.load php5.conf php5.load proxy_balancer.load proxy.conf proxy.load 
    reqtimeout.conf reqtimeout.load rewrite.load setenvif.conf setenvif.load ssl.conf ssl.load status.conf status.load
                   )
  def self.prepare_apache
    line="Include /home/yopiwww/conf/apache-sites/*.conf"
    File.open("/etc/apache2/apache2.conf","r+") do |f|
      lines=f.readlines
      f.puts line unless lines.include?(line)
    end
    @@apache_modules.each do |mod|
      system("ln -sf /etc/apache2/mods-available/#{mod} /etc/apache2/mods-enabled/")
    end
  end
  def self.prepare_mysql

  end
  def self.setup_logrotate
      conf =<<CONFIG
# Rotate Rails application logs
/home/yopiwww/sites/*/shared/log/*.log {
  size 200M
  missingok
  rotate 7
  compress
  delaycompress
  notifempty
  copytruncate
}
CONFIG
    File.open("/etc/logrotate.d/rails_apps","w") do |f|
      f.puts conf
    end
  end
end

def update_remote_mounts
  fstab=SystemConfigFile.new("/etc/fstab")
  remote_mount="192.168.50.50:/export /home/yopiwww/remote  glusterfs defaults,_netdev  0 0\n"
  fstab.append([remote_mount],remote_mount)
  system("mkdir -p /home/yopiwww/remote&&chown yopiwww:yopiwww /home/yopiwww/remote")
  system("mount /home/yopiwww/remote")
end

def prepare_services
  tasks=ConfigFile.find_opt("#{$local_host_name}-task")
  Services.setup_logrotate
  Services.prepare_apache if tasks and tasks.include?("web")
  Services.prepare_mysql if tasks and tasks.include?("db")
end

def update_host_file
  hosts=SystemConfigFile.new("/etc/hosts")
  hosts.append(ConfigFile.get_clean_file,"#DON'T CHANGE ANYTHING MANUALLY BENEATH THIS LINE")
  #hosts_file="/etc/hosts"
  #print "Update #{hosts_file}..\n"
  #host_lines=[]
  #File.open(hosts_file,"r") do |f|
    #server_def_found=false
    #while not server_def_found and not f.eof
      #line=f.readline 
      #if line.include?("#DON'T CHANGE ANYTHING MANUALLY BENEATH THIS LINE")
        #server_def_found=true
      #else
        #host_lines.push line
      #end
    #end
  #end
  #host_lines=host_lines+ConfigFile.get_clean_file
  #File.open(hosts_file,'w').write host_lines.join 
end

def update_ssh_config
  print "Configure SSH for user yopiwww..\n"
  key_file_name="revolution_rsa.pub"
  ssh_dir="/home/yopiwww/.ssh"
  auth_key_file_name="/authorized_keys"
  Dir.mkdir(ssh_dir) unless Dir.exist? ssh_dir
  File.chmod(0755,ssh_dir)
  chmod_yopiwww(ssh_dir)
  key_file=File.open(key_file_name,'r').readlines.join
  File.open(ssh_dir+auth_key_file_name,"w") do |f|
    f.write key_file
    f.chmod(0600)
  end
#  chmod_yopiwww(ssh_dir+auth_key_file_name)
  File.open(ssh_dir+"/config","w") do |f|
    f.puts("Host #{Host.get_ip("git_host")}")
    f.puts("  User git")
    f.puts("  StrictHostKeyChecking no")
    f.puts("  IdentityFile ~/.ssh/git_id_rsa")
    f.chmod(0600)
  end
  `cp git_id_rsa* /home/yopiwww/.ssh/`
  chmod_yopiwww("#{ssh_dir}/*")
end

def chmod_yopiwww(file)
  `chown yopiwww:yopi #{file}`
end

def update_hostname
  print "set hostname to #{$local_host_name}..\n"
  File.open("/etc/hostname",'w') do |f|
    f.puts $local_host_name 
  end
end

def update_mta_config
  config_file="/etc/postfix/main.cf"
  tasks = ConfigFile.find_opt("#{$local_host_name}-task")
  print "Update #{config_file} (Roles: #{tasks.inspect}) ..\n"
  configs = {
    :other => {
      :myhostname      => "#{$local_host_name}",
      :mydestination   => "#{$local_host_name}.yopi.de, #{$local_host_name}, localhost.localdomain, localhost",
      :relayhost       => '192.168.50.1',
      :inet_interfaces => 'loopback-only'
    },
    :web => {
      :smtpd_banner    => 'mail.yopi.de ESMTP $mail_name (Ubuntu)', #'$myhostname ESMTP $mail_name (Ubuntu)',
      :delay_warning_time => '4h',
      :myhostname      => "#{$local_host_name}.yopi.de",
      :myorigin        => :remove,
      :mydestination   => "yopi.de, #{$local_host_name}.yopi.de, #{$local_host_name}, localhost.localdomain, localhost",
      :relayhost       => '', 
      :mynetworks      => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 192.168.50.0/24',
      :inet_interfaces => 'all'
    }
  }
  if tasks and tasks.include?("web")
    role = :web
  else
    role = :other
  end
  config = configs[role]
  config_lines = []
  File.open(config_file, 'r') do |f|
    while not f.eof
      line = f.readline 
      if line.include?('=')
        parts = line.split('=').map{|p| p.strip}
        key = parts.first.gsub(/^#/,'').to_sym
        if config.keys.include?(key)
          line = "#{key} = #{config[key]}\n"
        end
      end
      config_lines << line
    end
  end
  File.open(config_file, 'w').write(config_lines.join)
end

options={}
OptionParser.new do |opts|
  opts.banner = "Usage: network.rb -f file [options]"
  opts.on_head("-f SERVER_DEF_FILE","--file SERVER_DEF_FILE",
               "use spezified server definitions") {|file|
    $server_file_name=file
    ConfigFile.read
    Host.set_local_host
    if $local_ext_ip
      print "Info: #{$local_host_name} - #{$local_ext_ip}\n"
    else
      print "This config file seems not to fit this server.\n"
      print "Please provide a proper config file with option -f.\n"
      exit
    end
  }
  opts.on("-H","--hosts",
          "Update /etc/hosts file") do
    update_host_file
          end
  opts.on("-V","--vpn","update vpn config") do
    puts "N2N VPN IS NOT IN USE ANYMORE!"
    #VPN.write_config
  end
  opts.on("-S","--ssh","update ssh key config") do
    update_ssh_config
  end
  opts.on("-N","--hostname","update hostname") do
    update_hostname
  end
  opts.on("-C","--config","Configure services for this host") do
    update_remote_mounts
    prepare_services
  end
  opts.on("-M","--mta", "update mta config") do
    update_mta_config
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

