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

echo "Adjusting permissions for the tomcat user and group"
cd /opt/tomcat
chgrp -R "${2}" /opt/tomcat
chmod -R g+r conf
chmod g+x conf

chown -R "${1}" webapps/ work/ temp/ logs/

echo "Creating the systemd unit at /etc/systemd/system/tomcat.service"
cat > /etc/systemd/system/tomcat.service <<-EOF
[Unit]
Description=Apache Tomcat 8.5.x Web Application Container
Wants=network.target
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/java/default
Environment=JRE_HOME=$JAVA_HOME/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Xms256M -Xmx512M'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
SuccessExitStatus=143

User=${1}
Group=${2}
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd"
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

