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
fi

read -p "New port: " port
sed -i -e "/^.\?Port\s[0-9]\+/s/.\?Port [0-9]\+/Port $port/;\
 /.\?PermitRootLogin/s/\s[a-z]\+-\?[a-z]\+/ no/;\
 /.\?PermitRootLogin/s/#//;\
 /.\?PubkeyAuthentication/s/\s[a-z]\+/ yes/;\
 /.\?PubkeyAuthentication/s/#//;\
 /.\?PasswordAuthentication/s/\s[a-z]\+/ no/;\
 /.\?PasswordAuthentication/s/#//;" /etc/ssh/sshd_config

firewall-cmd --permanent --zone=public --add-port=$port/tcp
firewall-cmd --reload

yum install -y policycoreutils-python
semanage port -a -t ssh_port_t -p tcp $port

systemctl restart sshd
