#!/bin/bash

if [ $EUID -ne 0 ]
then
echo Error: script not running by sudo
exit
fi

yum install -y epel-release &&
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm &&
yum install -y postgresql15-server policycoreutils-python &&

/usr/pgsql-15/bin/postgresql-15-setup initdb &&
systemctl enable postgresql-15 &&
systemctl start postgresql-15 &&

read -sp "New password for user \"postgres\": " pos_pass &&
echo $pos_pass | passwd postgres --stdin &&

rpm -i https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-redhat-repo-2-1.noarch.rpm &&
yum install -y pgadmin4-web &&

/usr/pgadmin4/bin/setup-web.sh &&
``
read -p "Name for new database: " db &&
read -p "Name for new superuser: " username &&
read -sp "Password for new superuser $username: " usr_pass &&

echo $pos_pass | su -c "psql -d postgres -c \"create database $db;\"" postgres 2> /dev/null &&
echo $pos_pass | su -c "psql -d postgres -c \"create user $username with login superuser password '$usr_pass';\"" postgres 2> /dev/null &&

firewall-cmd --permanent --add-service=http &&
firewall-cmd --reload
