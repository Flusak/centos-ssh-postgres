@echo off
set key=%2

set /P user="User: "
set /P host="Host: "

::проверка доступности хоста
ping %host% -n 2 > ping.txt
findstr "Request timed out." .\ping.txt >nul
if not errorlevel 1 (
    @echo Error: can`t ping %host%
    del .\ping.txt
    exit
)
del .\ping.txt

set /P port="Port: "
set keydef=%userprofile%\.ssh\id_rsa

::проверка ключа
if "%1"=="-i" (
    @type %key% 2>nul >nul
    if errorlevel 1 (
        @echo Error: key not found
        exit
    ) else (
        set usekey=-i %key%
    )
) else (
    @type %keydef% 2>nul >nul
    if errorlevel 1 (
        set usekey= 
    ) else set usekey=-i %keydef%
)


scp %usekey% -P %port% ./vol/pgadmin_nginx.sh ./vol/pgadmin_start.sh ./vol/pga.conf %user%@%host%:.
ssh %usekey% -p %port% -t %user%@%host% "sudo bash pgadmin_nginx.sh && rm -r ./pga.conf ./pgadmin_nginx.sh"

pause