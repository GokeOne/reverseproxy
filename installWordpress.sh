#!/bin/bash

#Instalacion de apache, php y extensiones necesarias.
apt update
apt install -y apache2 libapache2-mod-php mysql-client php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip unzip

#Habilitamos el modulo php y el remoteip.
a2enmod php*
a2enmod remoteip

#Pedimos la ip de red
echo "En caso de error cambiar ip de red en /etc/apache2/apache2.conf"
read -p "Introduce la ip de red donde estara colocado el proxy. ej: 10.0.2.0/24: " ipred

#Añadimos la configuracion de headers de proxy.
echo "RemoteIPHeader X-Forwarded-For" | tee -a /etc/apache2/apache2.conf
echo "RemoteIPInternalProxy $ipred" | tee -a /etc/apache2/apache2.conf

#Instalacion de wordpress
cd /tmp
wget https://es.wordpress.org/latest-es_ES.zip
mkdir -p /var/www/cms-web/
unzip latest-es_ES.zip -d /var/www/cms-web/
mv /var/www/cms-web/wordpress/* /var/www/cms-web/
chown -R www-data:www-data /var/www/cms-web/
chmod -R 755 /var/www/cms-web/

a2dissite 000-default.conf

cat <<EOF > /etc/apache2/sites-available/cms-web.conf
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/cms-web
	ServerAlias www.cms-web.com
	ErrorLog ${APACHE_LOG_DIR}/cms-web-error.log
	CustomLog ${APACHE_LOG_DIR}/cms-web-access.log combined
</VirtualHost>

EOF

a2ensite cms-web.conf
systemctl reload apache2
systemctl restart apache2
systemctl status apache2
