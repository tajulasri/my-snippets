#!/bin/sh

#minimal and dirty setup for laravel enviroment box
#mysql 5.7 / php 7.1 / apache 2 / redis / supervisor
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install software-properties-common -y

sudo add-apt-repository ppa:ondrej/php
sudo apt-get update

sudo apt-get install apache2 -y

sudo apt-get install -y php7.1 php7.1-cli php7.1-common php7.1-mbstring php7.1-gd php7.1-intl php7.1-xml php7.1-mysql php7.1-redis php7.1-mcrypt php7.1-zip php7.1-pdo-pgsql php7.1-dom php7.1-bcmath
sudo apt-get install redis-server -y
sudo redis-cli PING
sudo apt-get install supervisor -y

supervisor="
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/html/php artisan queue:work redis --sleep=3 --tries=3
autostart=true
autorestart=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/html/storage/logs/laravel.log
"

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

sudo a2enmod rewrite

sudo echo "$supervisor" > "/etc/supervisor/conf.d/laravel-worker.conf"

sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start laravel-worker:*


echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections

sudo apt-get -y install mysql-server

sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

sudo mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS example DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci";

sudo service mysql restart

mysql --user="root" --password="root" -e "CREATE USER 'laravel'@'0.0.0.0' IDENTIFIED BY 'secret';"
mysql --user="root" --password="root" -e "GRANT ALL ON *.* TO 'laravel'@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
mysql --user="root" --password="root" -e "GRANT ALL ON *.* TO 'laravel'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
mysql --user="root" --password="root" -e "FLUSH PRIVILEGES;"

#sudo rm -f /etc/php/7.1/apache2/php.ini
#sudo cp /var/www/html/php.ini.default /etc/php/7.1/apache2/php.ini

echo "restarting service apache / redis / mysql"
sudo service redis restart
sudo service apache2 restart && service mysql restart > /dev/null
