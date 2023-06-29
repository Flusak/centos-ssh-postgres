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

nohup ./pgadmin4/bin/python3 ./pgadmin4/lib/python3.6/site-packages/pgadmin4/pgAdmin4.py  &

sleep 5 &&

green='\033[0;32m' &&
red='\033[0;31m' &&
endcolor='\033[0m' &&
num_try=0 &&

info=$(curl -I -o /dev/stdout --url http://localhost:80/ -s)
echo "Try to check \$ip_con:80" &&
while ! echo $info | grep -E ".*login\?.*" > /dev/null
do
    ((num_try+=1))
    if [ "$num_try" -ge "4" ]
    then
        echo -e "${red}Something went wrong... Try to run installation script again!${endcolor}"
        exit
    fi
    echo "$num_try: Failed. Trying to start pgadmin again..."
    for i in $(ps -aux | egrep "pgadmin4" | tr -s "\t " " "| cut -f2 -d' ')
    do
        kill -9 $i
        nohup ./pgadmin4/bin/python3 ./pgadmin4/lib/python3.6/site-packages/pgadmin4/pgAdmin4.py  &
        sleep 7
    done
done

if echo $info | grep -E ".*login\?.*" > /dev/null
then
    echo -e "${green}pgadmin is running!${endcolor}"
    exit
else
    echo -e "${red}Something went wrong... Try to run installation script again!${endcolor}"
    exit
fi
