#!/bin/bash
if [ $EUID -ne 0 ]
then
echo Error: script not running by sudo
exit
fi


if ! [ -d ./pgadmin4 ]
then
echo 'Can`t find a directory! Have you run a installation script?'
exit
fi

for i in $(ps -aux | egrep "pgadmin4" | tr -s "\t " " "| cut -f2 -d' ')
do
		kill -9 $i > /dev/null 2> /dev/null
done

green='\033[0;32m' &&
red='\033[0;31m' &&
endcolor='\033[0m' &&
num_try=0

nohup ./pgadmin4/bin/python3 ./pgadmin4/lib/python3.6/site-packages/pgadmin4/pgAdmin4.py  &
sleep 5 &&

info=$(curl -I -o /dev/stdout --url http://localhost:80/ -s) &&
while ! echo $info | grep -E ".*login\?.*" > /dev/null
do
	((num_try+=1))
    time_sleep=$((5 + num_try))
	echo "$num_try: Failed. Trying again in $time_sleep seconds..."
	for i in $(ps -aux | egrep "pgadmin4" | tr -s "\t " " "| cut -f2 -d' ')
	do
		kill -9 $i > /dev/null 2> /dev/null
	done
	nohup ./pgadmin4/bin/python3 ./pgadmin4/lib/python3.6/site-packages/pgadmin4/pgAdmin4.py  &
	sleep $time_sleep
    info=$(curl -I -o /dev/stdout --url http://localhost:80/ -s)
done

if echo $info | grep -E ".*login\?.*" > /dev/null
then
    echo -e "${green}pgAdmin is running!${endcolor}"
	exit
else
	echo -e "${red}Something went wrong...${endcolor}"
    exit
fi
