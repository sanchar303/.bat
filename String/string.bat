@echo off
title String Executable
goto declare
:main
choice /n /m "Enter: " /c abcdefghijklmnopqrstuvwxyz0195
cls
if %errorlevel% equ 1 goto a
if %errorlevel% equ 2 goto b
if %errorlevel% equ 3 goto c
if %errorlevel% equ 4 goto d
if %errorlevel% equ 5 goto e
if %errorlevel% equ 6 goto f
if %errorlevel% equ 7 goto g
if %errorlevel% equ 8 goto h
if %errorlevel% equ 9 goto i
if %errorlevel% equ 10 goto j
if %errorlevel% equ 11 goto k
if %errorlevel% equ 12 goto l
if %errorlevel% equ 13 goto m
if %errorlevel% equ 14 goto n
if %errorlevel% equ 15 goto o
if %errorlevel% equ 16 goto p
if %errorlevel% equ 17 goto q
if %errorlevel% equ 18 goto r
if %errorlevel% equ 19 goto s
if %errorlevel% equ 20 goto t
if %errorlevel% equ 21 goto u
if %errorlevel% equ 22 goto v
if %errorlevel% equ 23 goto w
if %errorlevel% equ 24 goto x
if %errorlevel% equ 25 goto y
if %errorlevel% equ 26 goto z
if %errorlevel% equ 27 goto space
if %errorlevel% equ 28 goto declare
if %errorlevel% equ 29 goto er
if %errorlevel% equ 30 goto refresh
goto eof

:dis
echo.>character.txt
set "getChar="
echo.[0] for SPACE
echo.[1] for RESET
echo.[9] for BACKSPACE
echo.[5] for REFRESH, add any text to 'character.txt' file to add it here.
echo.
echo. ~ %val% ~
echo. ~ %nn% ~
echo.
goto main

:space
set val=%val% 
goto dis

:declare
set "val="
set "nn="
goto dis

:er
if "%val%" neq "" (
	set val=%val:~0,-1%
)
goto dis

:refresh
set /p getChar=<character.txt
set val=%val%%getChar%
goto dis

:eof
del /f /q character.txt
echo.	Quitting. . .
timeout /t 2 >nul
exit

:a
set val=%val%a
set /a nn=%nn%+1
goto dis

:b
set val=%val%b
set /a nn=%nn%+2
goto dis

:c
set val=%val%c
set /a nn=%nn%+3
goto dis

:d
set val=%val%d
set /a nn=%nn%+4
goto dis

:e
set val=%val%e
set /a nn=%nn%+5
goto dis

:f
set val=%val%f
set /a nn=%nn%+6
goto dis

:g
set val=%val%g
set /a nn=%nn%+7
goto dis

:h
set val=%val%h
set /a nn=%nn%+8
goto dis

:i
set val=%val%i
set /a nn=%nn%+9
goto dis

:j
set val=%val%j
set /a nn=%nn%+10
goto dis

:k
set val=%val%k
set /a nn=%nn%+11
goto dis

:l
set val=%val%l
set /a nn=%nn%+12
goto dis

:m
set val=%val%m
set /a nn=%nn%+13
goto dis

:n
set val=%val%n
set /a nn=%nn%+14
goto dis

:o
set val=%val%o
set /a nn=%nn%+15
goto dis

:p
set val=%val%p
set /a nn=%nn%+16
goto dis

:q
set val=%val%q
set /a nn=%nn%+17
goto dis

:r
set val=%val%r
set /a nn=%nn%+18
goto dis

:s
set val=%val%s
set /a nn=%nn%+19
goto dis

:t
set val=%val%t
set /a nn=%nn%+20
goto dis

:u
set val=%val%u
set /a nn=%nn%+21
goto dis

:v
set val=%val%v
set /a nn=%nn%+22
goto dis

:w
set val=%val%w
set /a nn=%nn%+23
goto dis

:x
set val=%val%x
set /a nn=%nn%+24
goto dis

:y
set val=%val%y
set /a nn=%nn%+25
goto dis

:z
set val=%val%z
set /a nn=%nn%+26
goto dis