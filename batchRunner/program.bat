@echo off
set /p destinationAddress=<C:/Windows/programDestinationAddress.txt
if "%1" == "" (
	goto manual
)
set "arg=%1"
goto proceed

:manual
echo.This function calls any batch script located in "%destinationAddress%".
echo.
echo.	PROGRAM batchscriptFileName
echo.
echo.To change the destination address, change the context in file "C:/Windows/programDestinationAddress.txt"
echo.
list "%destinationAddress%"
goto eof

:proceed
"%destinationAddress%\%arg%"

:eof