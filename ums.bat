@echo off
setlocal enabledelayedexpansion
if not exist "users" (
    mkdir "users"
)

:menu
title User Management System
color 7
cls
echo Welcome to the User Management System!
echo -------------------------------------
echo 1. Login
echo 2. Signup
echo 3. List Users
echo 4. Exit

set /p "choice=Enter your choice: "

if "%choice%" equ "1" (
    call :login
) else if "%choice%" equ "2" (
    call :signup
) else if "%choice%" equ "3" (
    call :listUsers
) else if "%choice%" equ "4" (
    exit
) else (
    echo Invalid choice. Please try again.
    timeout /t 2 >nul
    goto :menu
)

:login
title Login
cls
set "username="
set "password="

echo Login
echo -----

set /p "username=Username: "
set /p "password=Password: "

if exist "users\%username%.txt" (
    for /f "usebackq tokens=1-6 delims=:" %%a in ("users\%username%.txt") do (
        if "%%a"=="%username%" (
            if "%%b"=="%password%" (
                echo Login successful!
                timeout /t 2 >nul
                call :viewProfile "%username%"
            ) else (
                echo Incorrect password.
                timeout /t 2 >nul
                call :menu
            )
        )
    )
) else (
    echo User not found.
    timeout /t 2 >nul
    call :menu
)

:signup
title Sign Up
cls
set "username="
set "password="
set "email="
set "phone="
set "color="
set "role=0"
set "verificationCode="
set "isVerified=0"

echo Signup
echo ------

set /p "username=Username: "

if not "%username%"=="" (
	if exist "users\%username%.txt" (
    		echo Username already exists. Please choose a different username.
    		timeout /t 2 >nul
    		goto :signup
	)

set /p "password=Password: "
set /p "email=Email: "
set /p "phone=Phone: "

echo Choose a color:
echo 1. Blue
echo 2. Green
echo 3. Aqua
echo 4. Red
echo 5. Purple
echo 6. Yellow
echo 7. White

set /p "choice=Enter your choice: "

if "%choice%" equ "1" (
    set "color=red"
) else if "%choice%" equ "2" (
    set "color=blue"
) else if "%choice%" equ "3" (
    set "color=green"
) else if "%choice%" equ "4" (
    set "color=yellow"
)

echo Choose a role:
echo 1. Admin
echo 2. User

set /p "choice=Enter your choice: "

if "%choice%" equ "1" (
    set "role=1"
)

:generateVerificationCode
setlocal enableDelayedExpansion
set "characters=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
set "verificationCode="
for /l %%i in (1,1,6) do (
    set /a "rand=!random! %% 62"
    for %%j in (!rand!) do set "verificationCode=!verificationCode!!characters:~%%j,1!"
)
endlocal & set "verificationCode=%verificationCode%"

echo Verification code: %verificationCode%
echo.

set /p "verificationCodeInput=Enter the verification code: "

if "%verificationCodeInput%" equ "%verificationCode%" (
    set "isVerified=1"
    echo Verification successful!
) else (
    echo Verification failed. Please try again.
    timeout /t 2 >nul
    goto :signup
)

set "date=%date%"
echo %username%:%password%:%email%:%phone%:%color%:%date%:%role%:%isVerified% > "users\%username%.txt"
echo Signup successful!
timeout /t 2 >nul
)
call :menu

:listUsers
color 7
title List Users
cls
echo List of Users
echo -------------


for /r %%F in (users\*.txt) do (
    for /f "usebackq tokens=1 delims=: " %%A in ("%%F") do (
        echo. %%A
    )
)

echo.
set "usernameChoice="
set /p "usernameChoice=Enter the username: "

if not "%usernameChoice%"=="" (
    if exist "users\%usernameChoice%.txt" (
        call :displayUserDetails "%usernameChoice%"
    ) else (
        echo User does not exist.
        timeout /t 2 >nul
        goto :listUsers
    )
) else (
    goto :menu
)

:viewProfile
title %~1
set "username=%~1"
cls
echo Profile
echo -------

for /f "usebackq tokens=1-9 delims=: " %%a in ("users\%username%.txt") do (
    echo Username: %%a
    echo Password: ******
    echo Email: %%c
    echo Phone: %%d
    echo Created Date: %%e %%f
    echo Color: %%g
    if "%%h"=="1" (
        echo Role: Admin
    ) else (
        echo Role: User
    )
    if "%%i"=="1" (
        echo Account Verified: Yes
    ) else (
        echo Account Verified: No
    )

if "%%g"=="blue" (
        color 1
    ) else if "%%g"=="green" (
        color 2
    ) else if "%%g"=="aqua" (
        color 3
    ) else if "%%g"=="red" (
        color 4
    ) else if "%%g"=="purple" (
        color 5
    ) else if "%%g"=="yellow" (
        color 6
    ) else if "%%g"=="white" (
        color 87
    )
)

echo.
echo 1. Refresh Profile
echo 2. Change Password
echo 3. Change Email
echo 4. Change Phone
echo 5. Change Username
echo 6. Change Color
echo 7. Delete Account
echo 8. Logout

set /p "choice=Enter your choice: "

if "%choice%" equ "1" (
    goto :viewProfile "%username%"
) else if "%choice%" equ "2" (
    call :changePassword "%username%"
) else if "%choice%" equ "3" (
    call :changeEmail "%username%"
) else if "%choice%" equ "4" (
    call :changePhone "%username%"
) else if "%choice%" equ "5" (
    call :changeUsername "%username%"
) else if "%choice%" equ "6" (
    call :changeColor "%username%"
) else if "%choice%" equ "7" (
    call :deleteAccount "%username%"
) else if "%choice%" equ "8" (
    call :logout
) else (
    echo Invalid choice. Please try again.
    timeout /t 2 >nul
    goto :viewProfile "%username%"
)

:displayUserDetails
title User Details
set "username=%~1"
cls
echo User Details
echo -----------

for /f "usebackq tokens=1-9 delims=: " %%a in ("users\%username%.txt") do (
    echo Username: %%a
    echo Password: ******
    echo Email: %%c
    echo Phone: %%d
    echo Created Date: %%e %%f
    echo Color: %%g
    if "%%h"=="1" (
        echo Role: Admin
    ) else (
        echo Role: User
    )
    if "%%i"=="1" (
        echo Account Verified: Yes
    ) else (
        echo Account Verified: No
    )

if "%%g"=="blue" (
        color 1
    ) else if "%%g"=="green" (
        color 2
    ) else if "%%g"=="aqua" (
        color 3
    ) else if "%%g"=="red" (
        color 4
    ) else if "%%g"=="purple" (
        color 5
    ) else if "%%g"=="yellow" (
        color 6
    ) else if "%%g"=="white" (
        color 87
    )
)

timeout /t 6 >nul
goto :listUsers

:changePassword
title Change Password
set "username=%~1"
cls
set "newPassword="

echo Change Password
echo --------------

set /p "newPassword=New Password: "

for /f "usebackq tokens=1-9 delims=:" %%a in ("users\%username%.txt") do (
    echo %%a:%newPassword%:%%c:%%d:%%e %%f:%%g:%%h:%%i > "users\%username%.txt"
)

echo Password changed successfully!
timeout /t 2 >nul
call :viewProfile "%username%"

:changeEmail
title Change Email
set "username=%~1"
cls
echo Change Email
echo -----------

set "newEmail="

set /p "newEmail=New Email: "

setlocal enableDelayedExpansion
for /f "usebackq tokens=1-9 delims=: " %%a in ("users\%username%.txt") do (
    echo %%a:%%b:!newEmail!:%%d:%%e %%f:%%g:%%h:%%i > "users\%username%.txt"
)
endlocal

echo Email changed successfully!
timeout /t 2 >nul
goto :viewProfile "%username%"

:changePhone
title Change Phone
set "username=%~1"
cls
echo Change Phone
echo ------------

set "newPhone="

set /p "newPhone=New Phone: "

setlocal enableDelayedExpansion
for /f "usebackq tokens=1-9 delims=: " %%a in ("users\%username%.txt") do (
    echo %%a:%%b:%%c:!newPhone!:%%e %%f:%%g:%%h:%%i > "users\%username%.txt"
)
endlocal

echo Phone changed successfully!
timeout /t 2 >nul
goto :viewProfile "%username%"

:changeUsername
title Change Username
set "username=%~1"
cls
echo Change Username
echo --------------

set "newUsername="

set /p "newUsername=New Username: "

if exist "users\%newUsername%.txt" (
    echo Username already exists. Please choose a different username.
    timeout /t 2 >nul
    goto :changeUsername "%username%"
)

setlocal enableDelayedExpansion
for /f "usebackq tokens=1-9 delims=: " %%a in ("users\%username%.txt") do (
    ren "users\%%a.txt" "!newUsername!.txt"
    echo !newUsername!:%%b:%%c:%%d:%%e %%f:%%g:%%h:%%i > "users\!newUsername!.txt"
)
endlocal

echo Username changed successfully!
timeout /t 2 >nul
goto :viewProfile "!newUsername!"

:changeColor
title Change Color
set "username=%~1"
cls
echo Change Color
echo ------------

set "newColor="

echo Choose a color:
echo 1. Blue
echo 2. Green
echo 3. Aqua
echo 4. Red
echo 5. Purple
echo 6. Yellow
echo 7. White

set /p "choice=Enter your choice: "

if "%choice%" equ "1" (
    set "newColor=blue"
) else if "%choice%" equ "2" (
    set "newColor=green"
) else if "%choice%" equ "3" (
    set "newColor=aqua"
) else if "%choice%" equ "4" (
    set "newColor=red"
) else if "%choice%" equ "5" (
    set "newColor=purple"
) else if "%choice%" equ "6" (
    set "newColor=yellow"
) else if "%choice%" equ "7" (
    set "newColor=white"
)

setlocal enableDelayedExpansion
for /f "usebackq tokens=1-9 delims=: " %%a in ("users\%username%.txt") do (
    echo %%a:%%b:%%c:%%d:%%e %%f:!newColor!:%%h:%%i > "users\%username%.txt"
)
endlocal

echo Color changed successfully!
timeout /t 2 >nul
goto :viewProfile "%username%"

:deleteAccount
title Delete Account
set "username=%~1"
cls
echo Delete Account
echo --------------

set "confirm="

set /p "confirm=Are you sure you want to delete your account? (y/n): "

if /i "%confirm%"=="y" (
    del "users\%username%.txt"
    echo Account deleted successfully!
    timeout /t 2 >nul
    call :menu
) else (
    echo Account deletion canceled.
    timeout /t 2 >nul
    goto :viewProfile "%username%"
)

:logout
title Logout
set "username="
cls
echo Logout
echo ------

echo You have been logged out.
timeout /t 2 >nul
goto :menu
