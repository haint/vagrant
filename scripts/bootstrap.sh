#!/bin/bash 

# Update sources
# apt-get update

# Install Apache Tomcat and GIT
apt-get install -y openjdk-6-jre-headless
apt-get install -y git-core
mkdir repository.git
cd repository.git
git --bare init

# Change owner for tomcat
#chown -R vagrant:vagrant /var/lib/tomcat6
