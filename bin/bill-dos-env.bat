
set PATH=%HOMEDRIVE%%HOMEPATH%\bin;y:\bin;%PATH%

net use y: /delete
net use y: \\192.168.168.109\home

cmd /k cd y:

