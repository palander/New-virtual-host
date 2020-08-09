#!/bin/bash

echo "Name of the new domain?"
read name
echo "Where do you want the webroot? (example. /var/www/newroot)"
read WEB_ROOT_DIR

mkdir $WEB_ROOT_DIR

touch $WEB_ROOT_DIR/index.html

chown -R www-data:www-data $WEB_ROOT_DIR

email=webmaster@$name
sitesEnable='/etc/apache2/sites-enabled/'
sitesAvailable='/etc/apache2/sites-available/'
sitesAvailabledomain=$sitesAvailable$name.conf
echo "Creating a vhost for $sitesAvailabledomain with a webroot $WEB_ROOT_DIR"

echo "
    <VirtualHost *:80>
      ServerAdmin $email
      ServerName $name
      ServerAlias www.$name
      DocumentRoot $WEB_ROOT_DIR
        ErrorLog /var/log/apache2/$name-error.log
        CustomLog /var/log/apache2/$name-access.log combined
      <Directory $WEB_ROOT_DIR/>
        Options Indexes FollowSymLinks
        AllowOverride all
      </Directory>
    </VirtualHost>" > $sitesAvailabledomain
echo -e $"\nNew Virtual Host Created\n"

sed -i "1s/^/127.0.0.1 $name\n/" /etc/hosts

a2ensite $name
service apache2 reload

echo "Done!"
echo "So on with the SSL-thing..."
sudo certbot --apache

echo "Your virtual host should now be up and ready."
