@Echo off
:start
set wifiEnabled=0 
set ethernetEnabled=0 

set win7=6.1

for /f "tokens=2 delims=[]" %%x in ('ver') do set WINVER=%%x
set WINVER=%WINVER:Version =%

if %WINVER:~0,3% EQU %win7% (set LAN=Local Area Connection& set WAN=Wireless Network Connection) ELSE (set LAN=Ethernet& set WAN=Wi-Fi)

Echo Ethernet Adapters & Echo ================= & Echo.

FOR /F %%A IN ('netsh interface show interface ^| find "Enabled" ^| find "Connected" ^| find "%LAN%"') DO (
  set /a ethernetEnabled+=1 )

Echo %ethernetEnabled% Enabled and Connected & Echo.



Echo Wifi Adapters & Echo ================= & Echo.
FOR /F %%A IN ('netsh interface show interface ^| find "Enabled" ^| find "Connected" ^| find "%WAN%"') DO (
 set /a wifiEnabled+=1 )
Echo %wifiEnabled% Enabled and Connected & Echo.

FOR /F "tokens=* USEBACKQ" %%F IN (`netsh interface show interface ^| find "Enabled" ^| find "Connected" ^| find "%LAN%"`) DO (
SET var=%%F
)
SET var=%var:~47,25%

rem if there is no connected LAN, and No wifi Enabled or Connected than enable wifi.
if "%var%" EQU "~47,25" if %wifiEnabled% EQU 0  goto enableWifi

rem if %ethernetEnabled% EQU 0 if %wifiEnabled% EQU 0 goto enableWifi

if "%var%" EQU "%LAN%" ( Echo Ethernet is Connected. ) ELSE (Echo Not an Ethernet or is Disconnected, No actions will be made.) & goto EOF

if %ethernetEnabled% EQU 0 if %wifiEnabled% GEQ 1 goto EOF

if %ethernetEnabled% GEQ 1 if %wifiEnabled% EQU 0 goto disconnectCheck



if %ethernetEnabled% GEQ %wifiEnabled% if %wifiEnabled% GEQ 1 (
ipconfig /release
Echo Disabling Wi-Fi Connection
netsh interface set interface "%WAN%" disable
ipconfig /renew ) Else (
Echo Enabling Wi-Fi Connection
netsh interface set interface "%WAN%" enable
)

Echo Running As Service - Do Not Close

goto start

:disconnectCheck
set ethernetCheck=0
FOR /F %%A IN ('netsh interface show interface ^| find "Enabled" ^| find "Connected" ^| find "%LAN%"') DO (
  set /a ethernetCheck+=1 )

  if %ethernetCheck% LSS %ethernetEnabled% goto enableWifi 

goto disconnectCheck

:enableWifi
echo Ethernet is Disconnected - Wifi will be enabled.
netsh interface set interface "%WAN%" enable
goto EOF
:EOF
pause
