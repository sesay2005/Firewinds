#!/bin/bash

# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

# install apache2
apt-get -y install apache2
sudo systemctl start apache2.service
sudo systemctl enable apache2.service
# Install PHP 7.2 and Related Modules
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:ondrej/php
# Then update and upgrade to PHP 7.2
sudo apt update
sudo apt install php7.2 libapache2-mod-php7.2 php7.2-common php7.2-sqlite3 php7.2-mysql php7.2-gmp php7.2-curl php7.2-intl php7.2-mbstring php7.2-xmlrpc php7.2-soap php7.2-ldap php7.2-gd php7.2-bcmath php7.2-xml php7.2-cli php7.2-zip
# After installing PHP 7.2, open PHP default configuration file for Apache2
sudo nano /etc/php/7.2/apache2/php.ini
# Restart Apache2 web server
sudo systemctl restart apache2.service
# Create a test file called phpinfo.php in Apache2 default root directory ( /var/www/html/)
sudo echo "<?php phpinfo( ); ?>" > /var/www/html/phpinfo.php
# Download Symfony Latest Release
sudo apt install curl git
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
cd /var/www/
sudo composer create-project symfony/skeleton symfony5
# Set the correct permissions for Symfony root directory and give Apache2 control
sudo chown -R www-data:www-data /var/www/symfony5/
sudo chmod -R 755 /var/www/symfony5/
# This file will control how users access Symfony 
sudo echo "<VirtualHost *:80>
     ServerAdmin admin@example.com
     DocumentRoot /var/www/symfony5/public
     ServerName example.com
     ServerAlias www.example.com

     <Directory /var/www/symfony5/public/>
          Options FollowSymlinks
          AllowOverride All
          Require all granted
     </Directory>

     ErrorLog ${APACHE_LOG_DIR}/error.log
     CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" /etc/apache2/sites-available/symfony.conf
sudo a2ensite symfony.conf
sudo systemctl restart apache2.service
