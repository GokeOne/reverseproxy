#!/bin/bash

#Actualizamos los repositorios.
apt-get update

#Instalamos el servidor apache
apt-get install -y apache2

#Instalamos el cliente de mysql para conectarse con la database
apt-get install -y mysql-client

#Instalamos el php para conexiones a la base de datos por ejemplo con muysqli
apt-get install -y php


#Habiltiamos el modulo php
a2enmod php*
#Habilitamos el modulo remoteip
a2enmod remoteip


#Pedimos la ip de red.
echo "ASEGURATE DE PONER LA IP Y LA MASCARA CORRECTAMENTE SINO SE TENDRA QUE CAMBIAR"
echo "A MANO EN /ETC/APACHE2/APACHE2.CONF"
read -p "Introduce la ip de red donde estara colocado tu proxy ej: 10.0.2.0/24: " ipred

#Añadimos la configuracion de headers de proxy.
echo "RemoteIPHeader X-Forwarded-For" | tee -a /etc/apache2/apache2.conf
echo "RemoteIPInternalProxy $ipred" | tee -a /etc/apache2/apache2.conf


cat <<EOF > /etc/apache2/sites-enabled/000-default.conf

<VirtualHost *:80>
	<Directory /var/www/html/>
#	    Allow from 192.168.27.0/24
#	    Require ip 192.168.27.0/24
	    Require all granted
	</Directory>


	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html


	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>

EOF

#Reiniciamos el servicio de apache.
systemctl restart apache2
systemctl status apache2
