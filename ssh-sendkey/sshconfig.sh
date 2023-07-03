#!/bin/bash

if [ $EUID -ne 0 ]
then
echo Error: script not running by sudo
exit
fi

read -p "New port: " port

sed -i -e "s/#Port 22/Port $port/;\
 s/#PermitRootLogin yes/PermitRootLogin no/;\
 s/#PubkeyAuthentication yes/PubkeyAuthentication yes/;\
 s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

firewall-cmd --permanent --zone=public --add-port=$port/tcp
firewall-cmd --reload

yum install -y policycoreutils-python
semanage port -a -t ssh_port_t -p tcp $port

systemctl restart sshd
