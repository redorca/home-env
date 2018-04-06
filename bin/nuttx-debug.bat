@echo off

set PROGRAM=arm-none-eabi-gdb
set COMMAND_FILE=configs\nrf52832_dk\scripts\arm-gdb.init
set IMAGE=nuttx

set CMD="%PROGRAM% --command=%COMMAND_FILE% %IMAGE%"


rem This file is the script to set path for ARM eabi tool chain.

set TL_PATH=%~dp0
set PATH=%TL_PATH%;%PATH%
set NUTTX_DIR=\src\zglue\tmp\nuttx

cd %NUTTX_DIR%

cmd /K cd %CD% 

exit

