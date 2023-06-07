@echo off
if not exist "users" (
    mkdir "users"
)

:menu
title User Management System
color 7
cls
set "loggedIn=0"
echo Welcome to the User Management System!
echo -------------------------------------
echo. 1. Login
echo. 2. Signup
echo. 3. List Users
echo. 4. Exit

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
    for /f "tokens=1-7 delims=:" %%a in (users\%username%.txt) do (
            if "%%b"=="%password%" (
                echo Login successful!
                timeout /t 2 >nul
                call :viewProfile "%username%"
            ) else (
                echo Incorrect password.
                timeout /t 2 >nul
                call :loginMenu "%username%"
            )
    )
) else (
    echo User not found.
    timeout /t 2 >nul
    call :loginMenu "%username%"
)

:loginMenu
title Login ^?
set "username=%~1"
echo.
echo. 1. Signup
echo. 2. Go to menu
echo. 3. Exit

set /p "choice=Enter your choice: "

if "%choice%" equ "1" (
    call :signup
) else if "%choice%" equ "2" (
    goto :menu
) else if "%choice%" equ "3" (
    exit
) else (
    echo Invalid choice. Please try again.
    timeout /t 2 >nul
    call :loginMenu "%username%"
)

:signup
title Sign Up
cls
set "username="
set "password="
set "email="
set "phone="
set "color="

echo Signup
echo ------

set /p "username=Username: "

if exist "users\%username%.txt" (
    echo Username already exists. Please choose a different username.
    timeout /t 2 >nul
    goto :signup
)

set /p "password=Password: "
set /p "email=Email: "
set /p "phone=Phone: "

echo Choose a color:
echo. 1. Blue
echo. 2. Green
echo. 3. Aqua
echo. 4. Red
echo. 5. Purple
echo. 6. Yellow
echo. 7. White

set /p "colorCode=Enter your choice: "

if "%colorCode%" equ "1" (
    set "color=blue"
) else if "%colorCode%" equ "2" (
    set "color=green"
) else if "%colorCode%" equ "3" (
    set "color=aqua"
) else if "%colorCode%" equ "4" (
    set "color=red"
) else if "%colorCode%" equ "5" (
    set "color=purple"
) else if "%colorCode%" equ "6" (
    set "color=yellow"
) else if "%colorCode%" equ "7" (
    set "color=white"
    set "colorCode=70"
)

set "date=%date%"
echo %username%:%password%:%email%:%phone%:%date%:%color%:%colorCode% > "users\%username%.txt"
echo Signup successful!
timeout /t 2 >nul
call :menu

:listUsers
title List Users
cls
echo List of Users
echo -------------


for /r %%F in (users\*.txt) do (
    for /f "tokens=1 delims=: " %%A in (%%F) do (
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
set "username=%~1"
title %username%
cls
echo Profile
echo -------

for /f "tokens=1-7 delims=:" %%a in (users\%username%.txt) do (
    echo Username: %%a
    echo Password: %%b
    echo Email: %%c
    echo Phone: %%d
    echo Created Date: %%e
    echo Color: %%f
    color %%g
)
if "%loggedIn%"=="0" (
    cscript data\welcome.vbs "%username%" >nul
    set "loggedIn=1"
)

echo.
echo 1. Refresh Profile
echo 2. Change Password
echo 3. Change Email
echo 4. Change Phone
echo 5. Change Username
echo 6. Change Color
echo 7. Logout
echo 8. Delete Account

set "choice="
set /p "choice=Enter your choice: "

if "%choice%" equ "1" (
    call :viewProfile "%username%"
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
    call :menu
) else if "%choice%" equ "8" (
    call :deleteAccount "%username%"
) else (
    echo Invalid choice. Please try again.
    timeout /t 2 >nul
    call :viewProfile "%username%"
)

:changePassword
title Change Password
set "username=%~1"
cls
set "newPassword="

echo Change Password
echo --------------

set /p "newPassword=New Password: "

for /f "tokens=1-6 delims=:" %%a in (users\%username%.txt) do (
    echo %%a:%newPassword%:%%c:%%d:%%e:%%f > "users\%username%.txt"
)

echo Password changed successfully!
timeout /t 2 >nul
call :viewProfile "%username%"

:changeEmail
title Change Email
set "username=%~1"
cls
set "newEmail="

echo Change Email
echo ------------

set /p "newEmail=New Email: "

for /f "tokens=1-6 delims=:" %%a in (users\%username%.txt) do (
    echo %%a:%%b:%newEmail%:%%d:%%e:%%f > "users\%username%.txt"
)

echo Email changed successfully!
timeout /t 2 >nul
call :viewProfile "%username%"

:changePhone
title Change Phone
set "username=%~1"
cls
set "newPhone="

echo Change Phone
echo ------------

set /p "newPhone=New Phone: "

for /f "tokens=1-6 delims=:" %%a in (users\%username%.txt) do (
    echo %%a:%%b:%%c:%newPhone%:%%e:%%f > "users\%username%.txt"
)

echo Phone changed successfully!
timeout /t 2 >nul
call :viewProfile "%username%"

:changeUsername
title Change Username
set "username=%~1"
cls
set "newUsername="

echo Change Username
echo ---------------

set /p "newUsername=New Username: "

if exist "users\%newUsername%.txt" (
    echo Username already exists. Please choose a different username.
    timeout /t 2 >nul
    call :changeUsername "%username%"
) else (
    ren "users\%username%.txt" "%newUsername%.txt"
    echo Username changed successfully!
    timeout /t 2 >nul
    call :viewProfile "%newUsername%"
)

:changeColor
title Change Color
set "username=%~1"
cls
set "newColor="

echo Change Color
echo ------------

echo Choose a color:
echo. 1. Blue
echo. 2. Green
echo. 3. Aqua
echo. 4. Red
echo. 5. Purple
echo. 6. Yellow
echo. 7. White

set /p "colorCode=Enter your choice: "

if "%colorCode%" equ "1" (
    set "newColor=blue"
) else if "%colorCode%" equ "2" (
    set "newColor=green"
) else if "%colorCode%" equ "3" (
    set "newColor=aqua"
) else if "%colorCode%" equ "4" (
    set "newColor=red"
) else if "%colorCode%" equ "5" (
    set "newColor=purple"
) else if "%colorCode%" equ "6" (
    set "newColor=yellow"
) else if "%colorCode%" equ "7" (
    set "newColor=white"
    set "colorCode=70"
)

for /f "tokens=1-6 delims=:" %%a in (users\%username%.txt) do (
    echo %%a:%%b:%%c:%%d:%%e:%newColor%:%colorCode% > "users\%username%.txt"
)

echo Color changed successfully!
timeout /t 2 >nul
call :viewProfile "%username%"

:deleteAccount
title Account Deletion
set "username=%~1"
cls
del /p users\%username%.txt
echo %username% deleted successfully!
timeout /t 2 >nul
call :menu

:displayUserDetails
title User Details
cls
set "username=%~1"

echo User Details
echo ------------

for /f "tokens=1-7 delims=:" %%a in (users\%username%.txt) do (
    echo Username: %%a
    echo Password: *******
    echo Email: %%c
    echo Phone: %%d
    echo Created Date: %%e
    echo Color: %%f
    color %%g
)

echo.
echo. Press any key for Main Menu. . .
pause>nul
goto :menu

goto :eof
