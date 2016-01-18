#!/bin/bash

#sudo apt-get install ntp
#
#sudo gedit /etc/ntp.conf
#
## You do need to talk to an NTP server or two (or three).
#server ptbtime1.ptb.de
#server ptbtime2.ptb.de
#server ptbtime3.ptb.de
#server time-a.nist.gov
#server time-b.nist.gov
#server pool.ntp.org
#server de.pool.ntp.org
#server europe.pool.ntp.org
#server ntp.ubuntu.com

# mysql - root - g&s@my_sqlHE
# mysql - pma  - g&s@php_MY_adminHE
# user  - gswww - g&s@railsHE
# user  - gsrepo - g&s@mercurHE
# user  - gsmail - g&s@mailpasHE

roles="db web file app search cache lb lbcompl mail"
base_pkgs="openssh-server fail2ban htop iftop slurm dstat vim curl git-core byobu lsof lm-sensors sphinxsearch zip ntp" #glusterfs-client 
rvm_pkgs="build-essential bison openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev subversion"
lib_pkgs="libmagick++-dev libmysqlclient-dev"
lb_pkgs="openvpn shorewall"
db_pkgs="mysql-server mytop"
web_pkgs="nginx php5-fpm php5-mysql php5-suhosin" #"apache2 apachetop"
#cache_pkgs="squid3 squidclient"
cache_pkgs=""
appcache_pkgs="" #"memcache libmemcached-tools"
app_pkgs="" #"memcached libmemcached-tools"
search_pkgs="aspell libaspell-dev aspell-en aspell-de"
#file_pkgs="glusterfs-server"
file_pkgs=""
admin_pkgs="phpmyadmin"
lbcompl_pkgs=$lb $web $cache $appcache
mail_pkgs="dovecot-common dovecot-imapd" #dovecot-pop3d 
mta_pkgs="postfix"

#subroutines

command=$1

deb_install() {
  apt-get install $*
}

install_rvm() {
  curl -L get.rvm.io | bash -s stable --ruby
}

install_mail() {
  echo '# Protocols we want to be serving:' >> /etc/dovecot/dovecot.conf
  echo '#  imap imaps pop3 pop3s' >> /etc/dovecot/dovecot.conf
  echo 'protocols = imap imaps pop3 pop3s' >> /etc/dovecot/dovecot.conf

  adduser gsmail -s /usr/sbin/nologin
  echo 'info: gsmail' >> /etc/aliases
}

#install_webistrano() {
#    # ruby on rails
#    mkdir -p /home/gsrepo/sites
#    cd /home/gsrepo/sites
#    if [ -d /home/gsrepo/sites/webistrano ]; then
#      echo 'Create webistrano clone.'
#      git clone https://github.com/peritor/webistrano.git
#    else
#      echo 'Webistrano cloned already.'
#    fi
#    cp webistrano/database.yml /home/gsrepo/sites/webistrano/config/
#    
#    gemfile="/home/gsrepo/sites/webistrano/Gemfile"
#    echo "gem 'mongrel'" > $gemfile
#    echo "gem 'mongrel_cluster'" > $gemfile
#    echo "gem 'net-ssh', '2.0.15'" > $gemfile
#    echo "gem 'net-scp', '1.0.2'" > $gemfile
#    echo "gem 'net-sftp', '2.0.2'" > $gemfile
#    echo "gem 'net-ssh-gateway', '1.0.1'" > $gemfile
#    echo "gem 'highline', '1.5.1'" > $gemfile
#
#    # rvm
#    cp webistrano/.rvmrc /home/gsrepo/sites/webistrano
#    rvm rvmrc trust /home/gsrepo/sites/webistrano
#
#    # mysql - user
#    mysql -f -u root --password='g&s@my_sqlHE' --execute="use mysql; create user 'webistranosql'@'localhost' identified by 'web1stran0_sql';"
#    mysql -f -u root --password='g&s@my_sqlHE' --execute="use mysql; grant all on webistrano.* to 'webistranosql'@'localhost'"
#
#    # mysql - restore db-dump
#    if [ -f webistrano/webistrano.sql ]; then
#      mysql -f -u webistranosql --password='web1stran0_sql' --execute="drop database webistrano;"
#      mysql -f -u webistranosql --password='web1stran0_sql' --execute="create database webistrano;"
#      mysql -f -u webistranosql --password='web1stran0_sql' webistrano < webistrano/webistrano.sql
#    end
#
#    install_htpasswd
#}

install_webistrano() {
    # ruby on rails
    mkdir -p /home/gsrepo/sites
    cd /home/gsrepo/sites
    if [ -d /home/gsrepo/sites/webistrano ]; then
      echo 'Create webistrano clone.'
      git clone git://github.com/hewo/webistrano.git
    else
      echo 'Webistrano cloned already.'
    fi

    # rvm
    rvm rvmrc trust /home/gsrepo/sites/webistrano
    cd /home/gsrepo/sites/webistrano
    
    # mysql - user
    mysql -f -u root --password='g&s@my_sqlHE' --execute="use mysql; drop user 'webistranosql'@'localhost';"
    mysql -f -u root --password='g&s@my_sqlHE' --execute="flush privileges;"
    mysql -f -u root --password='g&s@my_sqlHE' --execute="use mysql; create user 'webistranosql'@'localhost' identified by 'web1stran0_sql';"
    mysql -f -u root --password='g&s@my_sqlHE' --execute="use mysql; grant all on webistrano.* to 'webistranosql'@'localhost';"
}


install_htpasswd() {
    touch /etc/nginx/.htpasswd
    htpasswd /etc/nginx/.htpasswd gsadmin
}

install_monit() {
    #install_htpasswd

    apt-get install monit

    cp monit/monit /etc/init.d/
    chown root:root /etc/init.d/monit
    chmod +x /etc/init.d/monit

    mkdir -p /etc/monit
    cp monit/monitrc /etc/monit/
    chown root:root /etc/monit/monitrc
}

install_git_repository() {
    mkdir -p /home/gsrepo/repositories/git
    cp repository/authors.txt /home/gsrepo/repositories/git/
    chown gsrepo:repo /home/gsrepo/repositories/git/authors.txt
    
    cd /home/gsrepo/repositories/git/
    echo '######################################################'
    echo '# git clone gsrepo@bf:repositories/git/brunch_finden #'
    echo '######################################################'
}

install_script_git_promt() {
    create_user

    mkdir -p /home/gswww/bin
    cp scripts/git-prompt.sh /home/gswww/bin/
    chown gswww:gswww /home/gswww/bin/git-prompt.sh
    chmod +x /home/gswww/bin/git-prompt.sh

    mkdir -p /home/gsrepo/bin
    cp git/git-prompt.sh /home/gsrepo/bin/
    chown gsrepo:gsrepo /home/gsrepo/bin/git-prompt.sh
    chmod +x /home/gsrepo/bin/git-prompt.sh
}

install_script_mysql_dump() {
    create_user

    mkdir -p /home/gswww/bin
    cp scripts/mysql_dump_brunch_finden.sh /home/gswww/bin/
    chown gswww:gswww /home/gswww/bin/mysql_dump_brunch_finden.sh
    chmod +x /home/gswww/bin/mysql_dump_brunch_finden.sh
}

use_rvm() {
  . "/usr/local/rvm/scripts/rvm"
}

prepare_system() {
  update-alternatives --set editor /usr/bin/vim.basic #use vim as default editor
  if test -z "`grep '%admin' /etc/sudoers`"
  then
    echo 'gswww ALL = NOPASSWD: /etc/init.d/nginx restart'
    echo '%admin ALL=(ALL) ALL' >> /etc/sudoers
  fi
}

prepare_rvm() {
  if test -z $rvm_version
  then
    rvm_line='[[ -s "/usr/local/rvm/scripts/rvm" ]] && . "/usr/local/rvm/scripts/rvm" # Load RVM function'
    if  test -z "`grep RVM /etc/bash.bashrc`"
    then
      echo $rvm_line >> /etc/bash.bashrc
    fi
    use_rvm
    rvm install ruby-1.9.3
    rvm use ruby-1.9.3 --default
    rvm gemset create rails3
    rvm use ruby-1.9.3@rails3

    rvm install ruby-1.8.7
    rvm use ruby-1.8.7 --default
    rvm gemset create rails238
    rvm use ruby-1.8.7@rails238

    gem install bundler
  fi
}

#commands

create_user() {
  addgroup admin

  addgroup bf
  adduser --ingroup bf --home /home/gswww/ gswww  
  adduser gswww admin
  adduser gswww rvm
  install_git_promt_script
  
  addgroup gsrepo
  adduser --ingroup gsrepo --home /home/gsrepo/ gsrepo
  adduser gsrepo admin
  adduser gsrepo rvm
}

do_install() {
#  server_ip=$2
  apt-get update
  echo "install on $server_ip."
  deb_install $base_pkgs $rvm_pkgs $lib_pkgs $mta_pkgs
  install_rvm
  prepare_rvm
  deb_install $(eval "echo \$$1_pkgs")
  if [ $1 = "mail" ]; then
    install_mail
  fi
  prepare_system
  create_user
  install_script_git_promt
  install_script_mysql_dump
}

do_network() {
 echo "Network install.." 
 use_rvm
 ruby network.rb --file $1 --hosts --hostname --vpn --ssh --config --mta
}

do_test() {
  echo $(eval "echo \$$1_pkgs")
}

help() {
  echo "Usage:"
  echo "  server-install.sh install <role>"
  echo "  server-install.sh test <role>"
  echo "  server-install.sh connect <host-file>"
  echo "  server-install.sh inst-rvm"
  echo "  server-install.sh create-user"
  echo ""
  echo "Role is one of [db|web|cache|app|search|file]."
  echo "Host-File must contain host definitions for this network."
  exit
}


#START
if [ "$UID" -ne "0" ]
then
  echo "Must be root to run this script."
  help
  exit 1
fi  


case $command in
  install) do_install $2;;
install-monit) install_monit;;
install-webistrano) install_webistrano;;
install-repository) install_git_repository;;
connect) do_network $2;;
inst-rvm) install_rvm;prepare_rvm;;
create-user) create_user;;
test) do_test $2;;
  *) help;;
esac



