#!/bin/bash 

# Update sources
# apt-get update

# Install Tomcat and GIT
apt-get install -y tomcat6 tomcat6-admin tomcat6-user git-core git-daemon-run

# Configure git daemon
sv stop git-daemon
sed -i 's/\/var\/cache\ \/var\/cache\/git/\/home\/vagrant/g' /etc/sv/git-daemon/run
sv start git-daemon

mkdir repository.git
cd repository.git
git --bare init
touch git-daemon-export-ok
cd .. && chown vagrant:vagrant -R repository.git

# Setup and configure Tomcat
echo -e "<tomcat-users>\n<role rolename=\"manager\"/>\n<user username=\"tomcat\" password=\"tomcat\" roles=\"manager\"/>\n</tomcat-users>" > "/etc/tomcat6/tomcat-users.xml"
service tomcat6 restart
