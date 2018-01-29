#!/bin/sh

##just sample and minimal vagrant script for laravel and postgresql / apache
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install software-properties-common -y

sudo add-apt-repository ppa:ondrej/php
sudo apt-get update

sudo apt-get install apache2 -y

#sudo apt-get install nginx -y

sudo apt-get install -y php7.1 php7.1-cli php7.1-common php7.1-mbstring php7.1-gd php7.1-intl php7.1-xml php7.1-mysql php7.1-mcrypt php7.1-zip php7.1-pdo-pgsql php7.1-dom php7.1-bcmath
#sudo apt-get install -y php7.1-fpm
sudo apt-get install php-redis


block="<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        #ServerName www.example.com

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/public

        <Directory /var/www/html/public>
                AllowOverride All
                Require all granted
        </Directory>
        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
"

#override original apache site conf
sudo rm -f /etc/apache2/sites-available/000-default.conf
echo "$block" > "/etc/apache2/sites-available/000-default.conf"

echo "restarting service apache"
sudo a2enmod rewrite


#run postgresql installation

sudo apt-get install postgresql-9.6

sudo -u postgres createdb example_database;
#sudo rm -f /etc/php/7.1/apache2/php.ini
#sudo cp /var/www/html/php.ini.default /etc/php/7.1/apache2/php.ini

sudo apt-get install redis-server

sudo service apache2 restart && sudo service postgresql restart > /dev/null
