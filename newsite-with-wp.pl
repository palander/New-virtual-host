#!/bin/bash

echo "You'll need to be ROOT to run this script."
echo "Name of the new domain? (example. domain.com or sub.domain.com)"
read name
echo "Where do you want the webroot? (example. /var/www/newroot) No trailing backslash!"
read WEB_ROOT_DIR
echo "Name for the new MySQL database (and user)?"
read new
echo "Ok, let's go!"

mkdir $WEB_ROOT_DIR

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
        Require all granted
      </Directory>
    </VirtualHost>" > $sitesAvailabledomain
echo -e $"\nNew Virtual Host Created\n"

sed -i "1s/^/127.0.0.1 $name\n/" /etc/hosts

a2ensite $name
service apache2 reload

echo "Done, please browse to http://$name to check!"

echo "So on with the SSL-thing..."
sudo certbot --apache

echo "Then we'll create the MySQL database for wordpress."

PASS=`pwgen -s 14 1`

mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $new;
CREATE USER '$new'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $new.* TO '$new'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "MySQL user created."
echo "Username:   $new"
echo "Password:   $PASS <--- You'll find this at root's home directory."
echo $PASS > /root/dbpass.txt

cd $WEB_ROOT_DIR
wget https://wordpress.org/latest.zip
unzip latest.zip
mv $WEB_ROOT_DIR/wordpress/* $WEB_ROOT_DIR
rm -rf $WEB_ROOT_DIR/latest.zip

chown -R www-data:www-data $WEB_ROOT_DIR

echo "Site should be up now! The DB password is in root's home directory."
