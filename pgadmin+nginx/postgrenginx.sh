if [ $EUID -ne 0 ]
then
echo Error: script not running by sudo
exit
fi

yum install -y epel-release &&
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm &&
yum install -y python3 python3-pip nginx postgresql15-server policycoreutils-python &&

mkdir -p /var/lib/pgadmin /var/log/pgadmin &&

chown $USER /var/lib/pgadmin /var/log/pgadmin &&

python3 -m venv pgadmin4 &&

#source pgadmin4/bin/activate
./pgadmin4/bin/pip install --upgrade pip --proxy http://proxy.infosec.ru:8080/ &&
./pgadmin4/bin/pip install pgadmin4 --proxy http://proxy.infosec.ru:8080/ &&

printf "HELP_PATH = '../../docs/en_US/_build/html/'\nMINIFY_HTML = False\nLOG_FILE = '/var/log/pgadmin4/pgadmin4.log'\nSQLITE_PATH = '/var/lib/pgadmin4/pgadmin4.db'\nSESSION_DB_PATH = '/var/lib/pgadmin4/sessions'\nSTORAGE_DIR = '/var/lib/pgadmin4/storage'\nSERVER_MODE = True\n" >> config_distro.py &&
mv -f ./config_distro.py pgadmin4/lib/python3.6/site-packages/pgadmin4/  &&
sed -i "/^DEFAULT_SERVER\s=\s./s/'127.0.0.1'/'0.0.0.0'/" pgadmin4/lib/python3.6/site-packages/pgadmin4/config.py &&

setenforce 0 &&
firewall-cmd --add-port=80/tcp --zone=public --permanent &&
firewall-cmd --reload  &&

mv -f ./pga.conf /etc/nginx/conf.d/ &&
systemctl restart nginx &&
echo "nginx restart" &&
/usr/pgsql-15/bin/postgresql-15-setup initdb &&
systemctl enable postgresql-15 &&
systemctl start postgresql-15 &&
echo "postgres start" &&
read -p "Ready to continue?" asdas &&
read -sp "New password for user \"postgres\": " pos_pass &&
echo $pos_pass | passwd postgres --stdin &&

read -p "Name for new database: " db &&
read -p "Name for new superuser: " username &&
read -sp "Password for new superuser $username: " usr_pass &&

echo $pos_pass | su -c "psql -d postgres -c \"create database $db;\"" postgres 2> /dev/null &&
echo $pos_pass | su -c "psql -d postgres -c \"create user $username with login superuser password '$usr_pass';\"" postgres 2> /dev/null &&



ip_con=$(ip a | egrep "inet[^6]" | egrep -v 127 |tr -s "\t " " "| cut -f3 -d' ' | cut -f1 -d/) &&
echo $ip_con:80 &&

echo -e "For connection to db in pgadmin use\n" &&
echo -e "Server: localhost\nUser:" $superuser &&

nohup ./pgadmin4/bin/python3 ./pgadmin4/lib/python3.6/site-packages/pgadmin4/pgAdmin4.py  &

sleep 5 &&
info=$(curl -I -o /dev/stdout --url http://localhost:80/ -s) &&
if echo $info | grep -E ".*login\?.*" > /dev/null
then
echo "Available. Exit..."
exit
else
for i in $(ps -aux | egrep "pgadmin4" | tr -s "\t " " "| cut -f2 -d' ')
do
kill -9 $i
done
echo "Not available"
fi