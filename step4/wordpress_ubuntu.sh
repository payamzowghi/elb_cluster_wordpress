#!/bin/bash

#variables and metadata
declare instance_address=$(curl http://169.254.169.254/latest/meta-data/public-hostname)

#update your system
sudo apt-get update && sudo apt-get upgrade -y

#Install Apache 2.4 from the Ubuntu repository
sudo apt-get install apache2 -y

#Edit the main Apache configuration file, apache2.conf, to adjust the KeepAlive setting
sudo sed -i "s/KeepAlive On/KeepAlive Off/g" /etc/apache2/apache2.conf

#open /etc/apache2/mods-available/mpm_prefork.conf and edit
sudo truncate /etc/apache2/mods-available/mpm_prefork.conf --size=0

#assign full acess to the file,get permision to edit
sudo chmod 777 /etc/apache2/mods-available/mpm_prefork.conf
sudo cat <<EOT >> /etc/apache2/mods-available/mpm_prefork.conf
<IfModule mpm_prefork_module>
        StartServers            4
        MinSpareServers         20
        MaxSpareServers         40
        MaxRequestWorkers       200
        MaxConnectionsPerChild  4500
</IfModule>
EOT

sudo chmod 644 /etc/apache2/mods-available/mpm_prefork.conf

#Disable the event module and enable prefork
sudo a2dismod mpm_event
sudo a2enmod mpm_prefork

#restart Apache
sudo systemctl restart apache2

#Create a copy of the default Apache configuration file for your site
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/$${instance_address}.conf

#open /etc/apache2/sites-available/example.com.conf and edit
sudo truncate /etc/apache2/sites-available/$${instance_address}.conf --size=0

#assign full acess to the file,get permision to edit 
sudo chmod 777 /etc/apache2/sites-available/$${instance_address}.conf

sudo cat <<EOT >> /etc/apache2/sites-available/$${instance_address}.conf 
<Directory /var/www/html/$${instance_address}/public_html>
    Require all granted
</Directory>
<VirtualHost *:80>
        ServerName $${instance_address}
        ServerAlias www.$${instance_address}
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/$${instance_address}/public_html

        ErrorLog /var/www/html/$${instance_address}/logs/error.log
        CustomLog /var/www/html/$${instance_address}/logs/access.log combined

</VirtualHost>
EOT

sudo chmod 644 /etc/apache2/sites-available/$${instance_address}.conf

#create the directories referenced above
sudo mkdir -p /var/www/html/$${instance_address}/{public_html,logs}

#Link my webserver file from the sites-available directory to the sites-enabled directory
sudo a2ensite $${instance_address}.conf 

#disable the default virtual host to minimize security risks
sudo a2dissite 000-default.conf

#reload apache:
sudo systemctl reload apache2

#Install the mysql-server package and choose a secure password
export DEBIAN_FRONTEND="noninteractive"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password rootpw"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password rootpw"

sudo apt-get install mysql-server -y

#create a MySQL database
sudo mysql --host=${db_address} --port=${db_port} --user=${db_user} --password=${db_password} <<MYSQL_SCRIPT
CREATE DATABASE webdata;
GRANT ALL ON webdata.* TO 'admin' IDENTIFIED BY 'pAyAm295';
MYSQL_SCRIPT

#Install PHP, the PHP Extension and Application Repository, Apache support, and MySQL support
sudo apt-get install php7.0 php-pear libapache2-mod-php7.0 php7.0-mysql -y 

#Once PHP7.0 is installed, edit the configuration file located in /etc/php/7.0/apache2/php.ini to enable more descriptive errors, logging, and better performance

sudo sed -i "s/max_input_time = 60/max_input_time = 30/g" /etc/php/7.0/apache2/php.ini
sudo sed -i "s/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_COMPILE_ERROR | E_RECOVERABLE_ERROR | E_ERROR | E_CORE_ERROR/g" /etc/php/7.0/apache2/php.ini
sudo sed -i -e "s/;error_log = php_errors\.log/error_log = \/var\/log\/php\/error.log/g" /etc/php/7.0/apache2/php.ini

#Create the log directory for PHP and give ownership to the Apache system user
sudo mkdir /var/log/php
sudo chown www-data /var/log/php

#restart apache2
sudo systemctl restart apache2

#create database for wordpress
sudo mysql --host=${db_address} --port=${db_port} --user=${db_user} --password=${db_password} <<MYSQL_SCRIPT 
CREATE DATABASE wordpress;
CREATE USER 'wpuser' IDENTIFIED BY 'pAyAm295';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser';
MYSQL_SCRIPT

#Create a directory called src under your website’s directory to store fresh copies of WordPress’s source files
sudo mkdir /var/www/html/$${instance_address}/src/
cd /var/www/html/$${instance_address}/src

#Set your web server’s user, www-data, as the owner of your site’s home directory:
sudo chown -R www-data:www-data /var/www/html/$${instance_address}/

#Install the latest version of WordPress and extract it:
sudo wget http://wordpress.org/latest.tar.gz
sudo -u www-data tar -xvf latest.tar.gz

#rename latest.tar.gz as wordpress followed by the date to store a backup of the original source files.
sudo mv latest.tar.gz wordpress-`date "+%Y-%m-%d"`.tar.gz

#Create a wordpress configuration using the sample: cp wordpress/wp-config-sample.php wordpress/wp-config.php
sudo cp wordpress/wp-config-sample.php wordpress/wp-config.php

#Update the wordpress configuration to specify the appropriate mysql database and user. Lines 23 - 38 should match:
sudo sed -i "s/define('DB_NAME', 'database_name_here');/define('DB_NAME', 'wordpress');/g" /var/www/html/$${instance_address}/src/wordpress/wp-config.php
sudo sed -i "s/define('DB_USER', 'username_here');/define('DB_USER', 'wpuser');/g" /var/www/html/$${instance_address}/src/wordpress/wp-config.php
sudo sed -i "s/define('DB_PASSWORD', 'password_here');/define('DB_PASSWORD', 'pAyAm295');/g" /var/www/html/$${instance_address}/src/wordpress/wp-config.php
sudo sed -i "s/define('DB_HOST', 'localhost');/define('DB_HOST', '"${db_address}"');/g" /var/www/html/$${instance_address}/src/wordpress/wp-config.php


#Move the WordPress files to your public_html folder:
sudo mv wordpress/* ../public_html/

#Make a directory for uploads (we will use this later):
sudo mkdir /var/www/html/$${instance_address}/public_html/wp-content/uploads

#Give my web server ownership of the public_html folder
sudo chown -R www-data:www-data /var/www/html/$${instance_address}/public_html


