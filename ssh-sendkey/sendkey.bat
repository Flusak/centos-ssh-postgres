@echo off

set key=%2
set keydef=%userprofile%\.ssh\id_rsa.pub

if "%1"=="-i" ( 
    goto checkey
    ) else (
        goto checkdef
)

:checkey
echo %key% | findstr ".pub" >nul
if errorlevel 1 (
    @echo Error: this is not a public key!
    exit
) else (
    type %key% 2>nul >nul
    if errorlevel 1 (
        @echo Error: key %key% not found.
        exit
    ) else (
        set usekey=%key%
        goto sshcopykey
    )
)

:checkdef
@type %keydef% 2>nul >nul
if errorlevel 1 (
    @echo Error: id_rsa.pub not found!
    exit
) else (
    set usekey=%keydef%
    goto sshcopykey
)

:sshcopykey
set /P user="User: "
set /P host="Host: "
type %usekey% | ssh %user%@%host% "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 0700 ~/.ssh && chmod 0644 ~/.ssh/authorized_keys"

scp -i %usekey:.pub=% ./sshconfig.sh %user%@%host%:.

ssh -t -i %usekey:.pub=% %user%@%host% "sudo bash sshconfig.sh"
