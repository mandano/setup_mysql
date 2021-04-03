#!/bin/bash

MYSQL_ROOT_PASSWORD=$(tr -cd a-zA-Z0-9 < /dev/urandom | head -c 30)
MYSQL_USER=$(tr -cd a-zA-Z0-9 < /dev/urandom | head -c 10)
MYSQL_USER_PASSWORD=$(tr -cd a-zA-Z0-9 < /dev/urandom | head -c 30)
MYSQL_DATABASE=$(tr -cd a-zA-Z0-9 < /dev/urandom | head -c 5)

cp env_example .env

sed -i -e "s/MYSQL_ROOT_PASSWORD=[a-zA-Z0-9]*/MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}/g" .env
sed -i -e "s/MYSQL_USER=[a-zA-Z0-9]*/MYSQL_USER=${MYSQL_USER}/g" .env
sed -i -e "s/MYSQL_USER_PASSWORD=[a-zA-Z0-9]*/MYSQL_USER_PASSWORD=${MYSQL_USER_PASSWORD}/g" .env
sed -i -e "s/MYSQL_DATABASE=[a-zA-Z0-9]*/MYSQL_DATABASE=${MYSQL_DATABASE}/g" .env

sudo apt-get install -y debconf-utils

DEBIAN_FRONTEND="noninteractive"

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"

#sudo debconf-get-selections | grep mysql

sudo apt-get install -y mysql-server

sudo mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE ${MYSQL_DATABASE}"
sudo mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER ${MYSQL_USER}@localhost IDENTIFIED BY '${MYSQL_USER_PASSWORD}';"
sudo mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';"

# Use legacy authentication
# echo "default_authentication_plugin=mysql_native_password" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart

history -cw
