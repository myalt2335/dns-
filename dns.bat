@echo off
setlocal enabledelayedexpansion
title DNS Configuration Script

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Can I have admin so I can work?
    powershell -Command "Start-Process cmd -ArgumentList '/c %~fnx0' -Verb RunAs"
    exit /b
)

set "logPath=%USERPROFILE%\Documents\dnslog.txt"
echo Log started at %date% %time% > "%logPath%"

:menu
cls
echo ==============================
echo    DNS Configuration Script  
echo ==============================
echo 1. Show active network adapters
echo 2. Set custom DNS
echo 3. Reset DNS to automatic
echo 4. Check current DNS settings
echo 5. Exit
echo ==============================
set /p "choice=Select an option (1-5): "


if "%choice%"=="1" goto show_adapters
if "%choice%"=="2" goto set_custom_dns
if "%choice%"=="3" goto reset_dns
if "%choice%"=="4" goto check_current_dns
if "%choice%"=="5" exit

echo Invalid option. Try again.
pause
goto menu

:show_adapters
cls
echo Active Network Adapters:
for /f "tokens=1,2,* delims= " %%A in ('netsh interface show interface ^| findstr /i "Connected"') do (
    set "adapter=%%C"
    
    for /f "tokens=* delims= " %%D in ("!adapter!") do set "adapter=%%D"

    echo - !adapter!
)
pause
goto menu

:set_custom_dns
cls
set /p "adapter=Enter the adapter name (press Enter for Wi-Fi): "
if "%adapter%"=="" set "adapter=Wi-Fi"

set /p "dns1=Enter primary DNS: "
if "%dns1%"=="" set "dns1=1.1.1.1"

set /p "dns2=Enter secondary DNS: "
if "%dns2%"=="" set "dns2=1.0.0.1"

echo Setting custom DNS on adapter: %adapter%
echo Primary DNS: %dns1%
echo Secondary DNS: %dns2%

netsh interface ip set dns name="%adapter%" static %dns1%
if not "%dns2%"=="" (
    netsh interface ip add dns name="%adapter%" addr=%dns2% index=2
)

echo DNS updated successfully on %adapter%!
pause
goto menu

:reset_dns
cls
set /p "adapter=Enter the adapter name: "
if "%adapter%"=="" set "adapter=Wi-Fi"

netsh interface ip set dns name="%adapter%" dhcp
echo DNS reset to automatic on %adapter%!
pause
goto menu

:check_current_dns
cls
echo Checking current DNS settings...
echo ==============================
powershell -Command "Get-DnsClientServerAddress"
pause
goto menu
 
