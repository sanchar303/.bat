@echo off
echo.Displays list of file/folder in the given directory.>listHelp.hlp
echo.>>listHelp.hlp
echo.	LIST ^[drive:^]^[path^]>>listHelp.hlp
echo.	LIST ^[drive:^]^[path^]filename>>listHelp.hlp
echo.               Type in the filename to view source code.>>listHelp.hlp
echo.>>listHelp.hlp
echo.Type LIST without parameters to perform default LIST function on current directory. >>listHelp.hlp

echo "%1" | find "." >nul
if errorlevel 1 (
	if "%1" == "/?" (
		goto getHelp
	) else if "%1" == "" (
		goto default
	) else (
		set "loc=%1"
		goto calculation
	)
) else (
	type "%1"
	goto eof
)

:getHelp
type listHelp.hlp
goto eof

:default
set "loc=%cd%"

:calculation
echo. Running ^(%loc%^). . .
echo.
dir "%loc%" /b >list.txt
setlocal enabledelayedexpansion
set "index=0"
for /f "delims=:" %%a in (list.txt) do (
	set /a index+=1
	echo %%a | find "." >nul
	if errorlevel 1 (
		echo.	!index!.	%%a		^(folder^)
	) else (
		echo.	!index!.	%%a		^(file^)
	)
)
endlocal
del /f /s list.txt >nul

:eof
del /f /s listHelp.hlp >nul