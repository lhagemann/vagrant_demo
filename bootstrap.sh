#!/usr/bin/env bash

# very basic LAMP install

apt-get update

# get our helpful build files installed
apt-get install build-essential


#install apache
apt-get install -y apache2
# link the default apache DOCUMENT_ROOT to our shared vagrant file
rm -rf /var/www
ln -fs /vagrant /var/www

# without a servername precise sets the server to 127.0.1.1 which breaks
# simple port forward to localhost; so name the server in apache 
echo "ServerName localhost" | sudo tee /etc/apache2/httpd.conf > /dev/null

## TODO ##
# add apache modules here with a2enmod <module>

#install php5
apt-get install php5 php5-cli libapache2-mod-php5 php5-mcrypt


# install MySQL
# set the root password for use during set up
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password your_password'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password your_password'
# pass -y to respond Y to terminal
apt-get -y install mysql-server php5-mysql

## TODO ##
# harden MySQL install: 
# * remove test db
# * give ourselves an admin user
# * prevent root login form other than localhost

