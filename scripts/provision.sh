#!/usr/bin/env bash

# Vagrant instance provision script
export DEBIAN_FRONTEND="noninteractive"

sudo apt-get update
sudo apt-get -y install apache2

# console tools
sudo apt-get -y install tmux git vim

# database 
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant'
sudo apt-get -y install mysql-server mysql-client

# php7
sudo apt-get -y install php7.0 php7.0-xml php7.0-curl php7.0-soap php7.0-gd php7.0-mbstring php7.0-mcrypt php7.0-mysql libapache2-mod-php

# debugging
sudo apt-get -y install vim-nox-py2 php-xdebug

# .. and other tools
sudo apt-get -y install composer

# clean up
sudo apt-get -y autoremove

# add webserver to ubuntu group 
sudo usermod -a -G ubuntu www-data

# enable apache modules
sudo a2enmod rewrite


block="xdebug.remote_enable=1
xdebug.remote_host=localhost
xdebug.remote_port=9000
"
sudo echo "$block" >> "/etc/php/7.0/apache2/20-xdebug.ini"

# restart apache
sudo service apache2 restart
