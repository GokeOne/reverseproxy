#!/bin/bash

#Funcion para validar una direccion ip.
validate_ip() {
	#Cogemos la primera opcion que ponemos junto a la funcion
	local ip=$1
	#Creamos las reglas para validar la ip.
	local reglas="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

	#Comparamos la ip con el patron de referencia, esto compara str
	if [[ $ip =~ $reglas ]]; then
		#Si coincide devuelve 0 que es True
		echo "IP valida."
		return 0
	else
		#Sino devuelve 1 que es false.
		echo "IP no válida. Pon una ip valida."
		return 1
	fi
}

#Actualizar repositorios e instalar Mysql
apt-get update
apt-get install -y mysql-server

#Pedimos la contraseña para el usuario root de mysql
read -p "Introduce la contraseña para el usuario root de mysql: " rootpass

#Pedimos informacion para la base de datos y usuario de apache
read -p "Introduce el nombre de la base de datos: " database
read -p "Nombre para el usuario admin del servidor apache: " adminapache
read -p "Contraseña para el usuario $adminapache: " contrapache

#Validamos la ip
while true; do
	read -p "IP del servidor apache: " ip_apache
	if validate_ip "$ip_apache"; then
		break
	fi
done


#Acceder a MYSQL y ejecutar comando sql para crear base de datos
#usuarios y cambiar la contraseña del root de sql
mysql -u root <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$rootpass';
FLUSH PRIVILEGES;
CREATE DATABASE $database;
CREATE USER '$adminapache'@'$ip_apache' IDENTIFIED BY '$contrapache';
GRANT ALL PRIVILEGES ON $database.* TO '$adminapache'@'$ip_apache';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Configuracion de MySQL completada"
conf="/etc/mysql/mysql.conf.d/mysqld.cnf"

cat <<EOF > "$conf"
[mysqld]
user		= mysql
# pid-file	= /var/run/mysqld/mysqld.pid
# socket	= /var/run/mysqld/mysqld.sock
# port		= 3306
# datadir	= /var/lib/mysql


bind-address		= 0.0.0.0
mysqlx-bind-address	= 0.0.0.0
#
# * Fine Tuning
#
key_buffer_size		= 16M
# max_allowed_packet	= 64M
# thread_stack		= 256K

# thread_cache_size       = -1

myisam-recover-options  = BACKUP

# max_connections        = 151

# table_open_cache       = 4000

# general_log_file        = /var/log/mysql/query.log
# general_log             = 1
#
# Error log - should be very few entries.
#
log_error = /var/log/mysql/error.log
# slow_query_log		= 1
# slow_query_log_file	= /var/log/mysql/mysql-slow.log
# long_query_time = 2
# log-queries-not-using-indexes
# server-id		= 1
# log_bin			= /var/log/mysql/mysql-bin.log
# binlog_expire_logs_seconds	= 2592000
max_binlog_size   = 100M
# binlog_do_db		= include_database_name
# binlog_ignore_db	= include_database_name

EOF

sudo systemctl restart mysql

echo "Archivo de configuracion creado en $conf. "
