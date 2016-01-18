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
    $server_file.each do |l|
      if l.include? host+"_"+suffix
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
end

module VPN
  BASE_DIR="/etc/n2n"
  def self.write_config
    print "Configure VPN..\n"
    self.get_vpn_data
    Dir.mkdir(BASE_DIR) unless File.exist?(BASE_DIR)
    self.write_edge_config
    if @@dispatcher==$local_host_name
      self.write_supernode_config
    end
    self.write_vpn_init_script
  end

  def self.write_edge_config
    key_file_name="/etc/n2n/key"
    File.open(key_file_name,"w") do |f|
      f.puts(@@password)
      f.chmod(0600)
    end
    File.open(BASE_DIR+"/edge.sh","w") do |f|
      f.puts("#!/bin/sh")
      f.puts("cat #{key_file_name}| xargs edge -a #{@@local_vpn_ip} "+
             "-c #{@@community} -l #{Host.ext_ip(@@dispatcher)}:6000 -k ")
      f.chmod(0700)
    end
  end

  def self.write_supernode_config
    File.open(BASE_DIR+"/supernode.sh","w") do |f|
      f.puts("#!/bin/sh\n")
      f.puts("supernode -l 6000")
      f.chmod(0700)
    end
  end

  def self.write_vpn_init_script
    init_file_name="/etc/init.d/n2n"
    File.open(init_file_name,"w") do |f|
      f.puts("#!/bin/sh")
      f.puts("/etc/n2n/edge.sh &")
      f.puts("/etc/n2n/supernode.sh &") if File.exist? "/etc/n2n/supernode.sh"
      f.chmod(0755)
    end
    `update-rc.d n2n defaults`
    puts "  *** To start VPN call /etc/init.d/n2n or reboot this machine. ***"
  end

  def self.get_vpn_data
    @@dispatcher=ConfigFile.find_opt("VPN_DISPATCHER")
    @@community=ConfigFile.find_opt("VPN_NAME")
    @@password=ConfigFile.find_opt("VPN_PWD")
    @@local_vpn_ip=Host.vpn_ip($local_host_name)
    print "  Configure with net #{@@community} by #{@@dispatcher}.\n"
  end

end

def update_host_file
  hosts_file="/etc/hosts"
  print "Update #{hosts_file}..\n"
  host_lines=[]
  File.open(hosts_file,"r") do |f|
    server_def_found=false
    while not server_def_found and not f.eof
      line=f.readline 
      if line.include?("#DON'T CHANGE ANYTHING MANUALLY BENEATH THIS LINE")
        server_def_found=true
      else
        host_lines.push line
      end
    end
  end
  host_lines=host_lines+ConfigFile.get_clean_file
  File.open(hosts_file,'w').write host_lines.join 
end

def update_ssh_config
  print "Configure SSH for user yopiwww..\n"
  key_file_name="revolution_rsa.pub"
  ssh_dir="/home/yopi/.ssh"
  auth_key_file_name="/authorized_keys"
  Dir.mkdir(ssh_dir) unless Dir.exist? ssh_dir
  File.chmod(0755,ssh_dir)
  `chown yopiwww:yopi #{ssh_dir}`
  key_file=File.open(key_file_name,'r').readlines.join
  File.open(ssh_dir+auth_key_file_name,"w") do |f|
    f.write key_file
    f.chmod(0600)
  end
  `chown yopiwww:yopi #{ssh_dir+auth_key_file_name}`
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
    VPN.write_config
  end
  opts.on("-S","--ssh","update ssh key config") do
    update_ssh_config
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

