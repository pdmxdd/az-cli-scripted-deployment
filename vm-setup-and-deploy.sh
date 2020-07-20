#!/bin/bash

# env vars needed by RunCommand

export DOTNET_CLI_HOME=/home/student
export HOME=/home/student
cd /home/student

# update apt-get repositories
apt-get update

### MySQL section START ###

# download the apt-get repository source package for MySQL
wget https://dev.mysql.com/get/mysql-apt-config_0.8.15-1_all.deb

# register the repository package with apt-get
sudo DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.15-1_all.deb

# update apt-get now that it has the new repo
apt-get update

# set environment variables that are necessary for MySQL installation
debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password lc-password"
debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password lc-password"

# install MySQL in a noninteractive way since the environment variables set the necessary information for setup
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server

# create a setup.sql file which will create our database, our user, and grant our user privileges to the database
cat >> setup.sql << EOF
CREATE DATABASE coding_events;
CREATE USER 'coding_events'@'localhost' IDENTIFIED BY 'launchcode';
GRANT ALL PRIVILEGES ON coding_events.* TO 'coding_events'@'localhost';
FLUSH PRIVILEGES;
EOF

# using the mysql CLI to run the setup.sql file as the root user in the mysql database
mysql -u root --password=lc-password mysql < setup.sql

# dotnet dependencies

wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo DEBIAN_FRONTEND=noninteractive dpkg -i packages-microsoft-prod.deb
sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-3.1





# deliver source code

git clone https://github.com/pdmxdd/coding-events-api
cd coding-events-api

# checkout branch that has the appsettings.json we need to connect to the KV
git checkout cli-deploy

cd CodingEventsAPI

# publish
dotnet publish -c Release -r linux-x64 -p:PublishSingleFile=true

# deploy in unattached process
sudo ASPNETCORE_URLS="http://*:80" ./bin/Release/netcoreapp3.1/linux-x64/publish/CodingEventsAPI&
