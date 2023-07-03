#!/bin/bash
if [ $EUID -ne 0 ]
then
echo Error: script not running by sudo
exit
fi

read -p "Input proxy (if not Enter): " useproxy
if ! [ -z "$useproxy" ]
then
echo "proxy=$useproxy" >> /etc/yum.conf
useproxy="--httpproxy $useproxy"
fi

yum install -y epel-release &&
if ! [ -e /etc/yum.repos.d/pgdg-redhat-all.repo ]
then
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
fi

rpm -i https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-redhat-repo-2-1.noarch.rpm $useproxy &&
yum install -y postgresql15-server policycoreutils-python pgadmin4-web &&

/usr/pgsql-15/bin/postgresql-15-setup initdb &&
systemctl enable postgresql-15 &&
systemctl start postgresql-15 &&

read -sp "New password for user \"postgres\": " pos_pass &&
echo $pos_pass | passwd postgres --stdin &&

read -p "Name for new database: " db &&
read -p "Name for new superuser: " username &&
read -sp "Password for new superuser $username: " usr_pass &&

echo $pos_pass | su -c "psql -d postgres -c \"create database $db;\"" postgres 2> /dev/null &&
echo $pos_pass | su -c "psql -d postgres -c \"create user $username with login superuser password '$usr_pass';\"" postgres 2> /dev/null &&

/usr/pgadmin4/bin/setup-web.sh &&

firewall-cmd --permanent --add-service=http &&
firewall-cmd --reload &&

ip_con=$(ip a | egrep "inet[^6]" | egrep -v 127 |tr -s "\t " " "| cut -f3 -d' ' | cut -f1 -d/) &&

echo "To connect to pgAdmin use: http://$ip_con:80/pgadmin4" 
echo -e "To connect to db use\nServer: localhost\nUser: $username"
