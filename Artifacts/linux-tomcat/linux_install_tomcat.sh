#!/bin/bash

# script to install tomcat manually from tarball.
#
# Parameters:
# $1 - Tomcat user
# $2 - Tomcat group

echo "Creating tomcat group: ${2}"
groupadd "${2}"

echo "Creating tomcat user: ${1}"
useradd -M -s /bin/nologin -g "${2}" -d /opt/tomcat "${1}"

echo "Installing Tomcat"
wget http://apache.mirror.serversaustralia.com.au/tomcat/tomcat-8/v8.0.52/bin/apache-tomcat-8.0.52.tar.gz

mkdir /opt/tomcat
tar xvf apache-tomcat-8.0.52.tar.gz -C /opt/tomcat --strip-components=1

cd /opt/tomcat
chgrp -R "${2}" /opt/tomcat
chmod -R g+r conf
chmod g+x conf

chown -R "${1}" webapps/ work/ temp/ logs/

systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

