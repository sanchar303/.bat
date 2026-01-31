@echo off
chcp 65001 > nul
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================
REM   PROFESSIONAL USER MANAGEMENT SYSTEM
REM   Version 2.0
REM ============================================

REM Initialize directories
if not exist "users" mkdir "users" >nul 2>&1
if not exist "bin"   mkdir "bin"   >nul 2>&1
if not exist "data"  mkdir "data"  >nul 2>&1

REM Check for welcome script
set "HAS_WELCOME_VBS=0"
if exist "data\welcome.vbs" set "HAS_WELCOME_VBS=1"

REM Global variables
set "currentUser="
set "welcomed=0"
set "VERSION=2.0"

REM ============================================
REM   MAIN MENU
REM ============================================
:menu
title User Management System v!VERSION!
color 0B
cls
echo.
echo  ================================================
echo       USER MANAGEMENT SYSTEM v!VERSION!
echo  ================================================
echo.
echo    [1] Login to Account
echo    [2] Create New Account
echo    [3] View All Users
echo    [4] Exit System
echo.
echo  ================================================
echo.

choice /c 1234 /n /m "  Select an option (1-4): "
set "menuChoice=!errorlevel!"

if "!menuChoice!"=="1" goto login
if "!menuChoice!"=="2" goto signup
if "!menuChoice!"=="3" goto listUsers
if "!menuChoice!"=="4" goto exitSystem

goto menu


REM ============================================
REM   LOGIN SECTION
REM ============================================
:login
title Login - User Management System
color 0E
cls
echo.
echo  ================================================
echo                    LOGIN
echo  ================================================
echo.

set "username="
set /p "username=  Username: "
call :trim username

if "!username!"=="" (
    echo.
    echo  [!] Username cannot be empty.
    timeout /t 2 >nul
    goto login
)

call :validateUsername "!username!"
if errorlevel 1 (
    echo.
    echo  [!] Invalid username format.
    echo  [i] Rules: 3-20 characters, letters, numbers, _ and - only
    timeout /t 3 >nul
    goto login
)

set "userFile=users\!username!.ini"
if not exist "!userFile!" (
    echo.
    echo  [!] Username not found.
    echo.
    choice /c YN /n /m "  Would you like to create this account? (Y/N): "
    if !errorlevel!==1 (
        set "signupUsername=!username!"
        goto signupWithUser
    )
    goto login
)

set "password="
set /p "password=  Password: "

if "!password!"=="" (
    echo.
    echo  [!] Password cannot be empty.
    timeout /t 2 >nul
    goto login
)

call :validatePassword "!password!"
if errorlevel 1 (
    echo.
    echo  [!] Invalid password format.
    timeout /t 2 >nul
    goto login
)

call :readValue "!userFile!" "password" storedPass

if "!storedPass!"=="" (
    echo.
    echo  [!] Account data corrupted. Please contact administrator.
    timeout /t 3 >nul
    goto menu
)

if "!password!"=="!storedPass!" (
    set "currentUser=!username!"
    set "welcomed=0"
    set "password="
    echo.
    echo  [✓] Login successful! Welcome back, !username!
    timeout /t 2 >nul
    goto profile
) else (
    set "password="
    echo.
    echo  [!] Incorrect password. Please try again.
    timeout /t 2 >nul
    goto login
)


REM ============================================
REM   SIGNUP SECTION
REM ============================================
:signup
set "signupUsername="

:signupWithUser
title Signup - User Management System
color 0A
cls
echo.
echo  ================================================
echo                    SIGNUP
echo  ================================================
echo.

if defined signupUsername (
    set "username=!signupUsername!"
    echo  [i] Creating account for: !signupUsername!
    echo.
) else (
    set "username="
    set /p "username=  Choose a username: "
    call :trim username
    
    if "!username!"=="" (
        echo.
        echo  [!] Username cannot be empty.
        timeout /t 2 >nul
        goto signup
    )
)

call :validateUsername "!username!"
if errorlevel 1 (
    echo.
    echo  [!] Invalid username format.
    echo  [i] Rules: 3-20 characters, letters, numbers, _ and - only
    timeout /t 3 >nul
    set "signupUsername="
    goto signup
)

set "userFile=users\!username!.ini"
if exist "!userFile!" (
    echo.
    echo  [!] Username already exists. Please choose another.
    timeout /t 2 >nul
    set "signupUsername="
    goto signup
)

set "password="
set /p "password=  Choose a password: "

if "!password!"=="" (
    echo.
    echo  [!] Password cannot be empty.
    timeout /t 2 >nul
    goto signupWithUser
)

call :validatePassword "!password!"
if errorlevel 1 (
    echo.
    echo  [!] Invalid password format.
    echo  [i] Rules: 4-30 characters, letters, numbers, _ - @ # . only
    timeout /t 3 >nul
    goto signupWithUser
)

set "email="
set "phone="
set /p "email=  Email (optional): "
set /p "phone=  Phone (optional): "

call :getTimestamp createdAt
call :pickColor colorName colorCode

> "!userFile!" (
    echo username=!username!
    echo password=!password!
    echo email=!email!
    echo phone=!phone!
    echo created=!createdAt!
    echo colorname=!colorName!
    echo colorcode=!colorCode!
)

set "password="
set "signupUsername="
echo.
echo  [✓] Account created successfully!
echo  [i] You can now login with your credentials.
timeout /t 3 >nul
goto menu


REM ============================================
REM   LIST USERS
REM ============================================
:listUsers
title User Directory - User Management System
color 0D
cls
echo.
echo  ================================================
echo                 USER DIRECTORY
echo  ================================================
echo.
echo  [i] Registered Users:
echo.

set "found=0"
set "count=0"
for %%F in ("users\*.ini") do (
    set "found=1"
    set /a count+=1
    echo    !count!. %%~nF
)

if "!found!"=="0" (
    echo    (No users registered yet)
)

echo.
echo  ================================================
echo.
echo  Press any key to return to main menu...
pause >nul
goto menu


REM ============================================
REM   PROFILE SECTION
REM ============================================
:profile
set "userFile=users\!currentUser!.ini"
if not exist "!userFile!" (
    color 0C
    cls
    echo.
    echo  [!] Profile file missing or corrupted.
    timeout /t 2 >nul
    goto menu
)

call :readValue "!userFile!" "username"   u
call :readValue "!userFile!" "email"      e
call :readValue "!userFile!" "phone"      p
call :readValue "!userFile!" "created"    c
call :readValue "!userFile!" "colorname"  cn
call :readValue "!userFile!" "colorcode"  cc

if "!cc!"=="" set "cc=0B"
color !cc!

REM Show welcome message once per session
if "!welcomed!"=="0" (
    if "!HAS_WELCOME_VBS!"=="1" (
        cscript //nologo "data\welcome.vbs" "!currentUser!" >nul 2>&1
    )
    set "welcomed=1"
)

title Profile: !u! - User Management System
cls
echo.
echo  ================================================
echo                  USER PROFILE
echo  ================================================
echo.
echo   Username      : !u!
echo   Password      : ••••••••
echo   Email         : !e!
echo   Phone         : !p!
echo   Created       : !c!
echo   Theme Color   : !cn!
echo.
echo  ================================================
echo.
echo   [1] Refresh Profile
echo   [2] Change Password
echo   [3] Update Email
echo   [4] Update Phone
echo   [5] Change Username
echo   [6] Change Theme Color
echo   [7] Edit Profile (Notepad)
echo   [8] Delete Account
echo   [9] Logout
echo.
echo  ================================================
echo.

choice /c 123456789 /n /m "  Select an option (1-9): "
set "profileChoice=!errorlevel!"

if "!profileChoice!"=="1" goto profile
if "!profileChoice!"=="2" goto changePassword
if "!profileChoice!"=="3" goto changeEmail
if "!profileChoice!"=="4" goto changePhone
if "!profileChoice!"=="5" goto changeUsername
if "!profileChoice!"=="6" goto changeColor
if "!profileChoice!"=="7" goto editProfile
if "!profileChoice!"=="8" goto deleteAccount
if "!profileChoice!"=="9" goto logout

goto profile


REM ============================================
REM   EDIT PROFILE IN NOTEPAD
REM ============================================
:editProfile
title Editing Profile - !currentUser!
echo.
echo  [i] Opening profile in Notepad...
start "" /wait notepad "!userFile!"
goto profile


REM ============================================
REM   CHANGE PASSWORD
REM ============================================
:changePassword
title Change Password - !currentUser!
cls
echo.
echo  ================================================
echo                CHANGE PASSWORD
echo  ================================================
echo.

set "oldPass="
set /p "oldPass=  Current password: "

if "!oldPass!"=="" (
    echo.
    echo  [i] Cancelled.
    timeout /t 1 >nul
    goto profile
)

call :readValue "!userFile!" "password" storedPass

if not "!oldPass!"=="!storedPass!" (
    echo.
    echo  [!] Current password is incorrect.
    timeout /t 2 >nul
    goto profile
)

set "newPass="
set /p "newPass=  New password: "

if "!newPass!"=="" (
    echo.
    echo  [i] Cancelled.
    timeout /t 1 >nul
    goto profile
)

call :validatePassword "!newPass!"
if errorlevel 1 (
    echo.
    echo  [!] Invalid password format.
    echo  [i] Rules: 4-30 characters, letters, numbers, _ - @ # . only
    timeout /t 3 >nul
    goto profile
)

call :writeValue "!userFile!" "password" "!newPass!"
echo.
echo  [✓] Password updated successfully!
timeout /t 2 >nul
goto profile


REM ============================================
REM   CHANGE EMAIL
REM ============================================
:changeEmail
title Change Email - !currentUser!
cls
echo.
echo  ================================================
echo                 CHANGE EMAIL
echo  ================================================
echo.

set "newEmail="
set /p "newEmail=  New email: "

if "!newEmail!"=="" (
    echo.
    echo  [i] Cancelled.
    timeout /t 1 >nul
    goto profile
)

call :writeValue "!userFile!" "email" "!newEmail!"
echo.
echo  [✓] Email updated successfully!
timeout /t 2 >nul
goto profile


REM ============================================
REM   CHANGE PHONE
REM ============================================
:changePhone
title Change Phone - !currentUser!
cls
echo.
echo  ================================================
echo                 CHANGE PHONE
echo  ================================================
echo.

set "newPhone="
set /p "newPhone=  New phone: "

if "!newPhone!"=="" (
    echo.
    echo  [i] Cancelled.
    timeout /t 1 >nul
    goto profile
)

call :writeValue "!userFile!" "phone" "!newPhone!"
echo.
echo  [✓] Phone updated successfully!
timeout /t 2 >nul
goto profile


REM ============================================
REM   CHANGE USERNAME
REM ============================================
:changeUsername
title Change Username - !currentUser!
cls
echo.
echo  ================================================
echo               CHANGE USERNAME
echo  ================================================
echo.

set "newUser="
set /p "newUser=  New username: "
call :trim newUser

if "!newUser!"=="" (
    echo.
    echo  [i] Cancelled.
    timeout /t 1 >nul
    goto profile
)

call :validateUsername "!newUser!"
if errorlevel 1 (
    echo.
    echo  [!] Invalid username format.
    echo  [i] Rules: 3-20 characters, letters, numbers, _ and - only
    timeout /t 3 >nul
    goto profile
)

if exist "users\!newUser!.ini" (
    echo.
    echo  [!] Username already exists. Please choose another.
    timeout /t 2 >nul
    goto profile
)

ren "!userFile!" "!newUser!.ini" >nul 2>&1
set "currentUser=!newUser!"
set "userFile=users\!currentUser!.ini"
call :writeValue "!userFile!" "username" "!currentUser!"

echo.
echo  [✓] Username updated successfully!
timeout /t 2 >nul
goto profile


REM ============================================
REM   CHANGE COLOR
REM ============================================
:changeColor
title Change Theme Color - !currentUser!
cls
echo.
echo  ================================================
echo               CHANGE THEME COLOR
echo  ================================================
echo.

call :pickColor newColorName newColorCode
call :writeValue "!userFile!" "colorname" "!newColorName!"
call :writeValue "!userFile!" "colorcode" "!newColorCode!"

echo.
echo  [✓] Theme color updated to !newColorName!!
timeout /t 2 >nul
goto profile


REM ============================================
REM   DELETE ACCOUNT
REM ============================================
:deleteAccount
title Delete Account - !currentUser!
cls
echo.
echo  ================================================
echo                DELETE ACCOUNT
echo  ================================================
echo.
echo  [WARNING] This will move your account to the bin folder.
echo  [WARNING] This action cannot be easily undone.
echo.

choice /c YN /n /m "  Are you sure you want to delete your account? (Y/N): "

if !errorlevel!==2 (
    echo.
    echo  [i] Account deletion cancelled.
    timeout /t 2 >nul
    goto profile
)

echo.
choice /c YN /n /m "  Final confirmation - Delete account? (Y/N): "

if !errorlevel!==2 (
    echo.
    echo  [i] Account deletion cancelled.
    timeout /t 2 >nul
    goto profile
)

move /Y "!userFile!" "bin\!currentUser!.ini" >nul 2>&1
echo.
echo  [✓] Account deleted successfully.
echo  [i] Your data has been moved to the bin folder.
timeout /t 3 >nul
set "currentUser="
set "welcomed=0"
goto menu


REM ============================================
REM   LOGOUT
REM ============================================
:logout
echo.
echo  [i] Logging out...
timeout /t 1 >nul
set "currentUser="
set "welcomed=0"
color 0B
goto menu


REM ============================================
REM   EXIT SYSTEM
REM ============================================
:exitSystem
color
cls
echo.
echo  ================================================
echo          Thank you for using our system!
echo  ================================================
echo.
timeout /t 2 >nul
exit /b 0


REM ============================================
REM   HELPER FUNCTIONS
REM ============================================

:trim
REM Trim whitespace from variable
set "var=%~1"
call set "str=%%%var%%%"
for /f "tokens=* delims= " %%A in ("!str!") do set "%var%=%%A"
exit /b


:validateUsername
REM Validate username: 3-20 chars, alphanumeric plus _ and -
setlocal
set "u=%~1"
if "!u!"=="" (endlocal & exit /b 1)
if "!u:~2,1!"=="" (endlocal & exit /b 1)
if not "!u:~20,1!"=="" (endlocal & exit /b 1)
echo(!u!| findstr /r "^[A-Za-z0-9_-][A-Za-z0-9_-]*$" >nul
if errorlevel 1 (endlocal & exit /b 1)
endlocal & exit /b 0


:validatePassword
REM Validate password: 4-30 chars, allowed special characters
setlocal
set "p=%~1"
if "!p!"=="" (endlocal & exit /b 1)
if "!p:~3,1!"=="" (endlocal & exit /b 1)
if not "!p:~30,1!"=="" (endlocal & exit /b 1)
echo(!p!| findstr /r "^[A-Za-z0-9_@#\.-][A-Za-z0-9_@#\.-]*$" >nul
if errorlevel 1 (endlocal & exit /b 1)
endlocal & exit /b 0


:getTimestamp
REM Get current date and time
set "%~1=!date! !time!"
exit /b


:readValue
REM Read a value from INI file
set "file=%~1"
set "key=%~2"
set "outVar=%~3"
set "!outVar!="
for /f "usebackq tokens=1* delims==" %%A in (`findstr /i /b "%key%=" "%file%" 2^>nul`) do (
    set "!outVar!=%%B"
    goto :eof
)
exit /b


:writeValue
REM Write or update a value in INI file
setlocal
set "file=%~1"
set "key=%~2"
set "value=%~3"
set "tmp=%temp%\usr_!random!!random!.tmp"
set "found=0"

break > "!tmp!"

for /f "usebackq delims=" %%L in ("%file%") do (
    set "line=%%L"
    for /f "tokens=1* delims==" %%A in ("%%L") do (
        if /i "%%A"=="%key%" (
            >>"!tmp!" echo %key%=%value%
            set "found=1"
        ) else (
            >>"!tmp!" echo %%L
        )
    )
)

if "!found!"=="0" >>"!tmp!" echo %key%=%value%
move /Y "!tmp!" "%file%" >nul 2>&1
endlocal & exit /b


:pickColor
REM Let user pick a theme color
set "cnVar=%~1"
set "ccVar=%~2"

echo.
echo  Choose your theme color:
echo.
echo   [1] Blue     (Professional)
echo   [2] Green    (Fresh)
echo   [3] Aqua     (Cool)
echo   [4] Red      (Bold)
echo   [5] Purple   (Creative)
echo   [6] Yellow   (Bright)
echo   [7] White    (Classic)
echo.

choice /c 1234567 /n /m "  Select a color (1-7): "
set "pick=!errorlevel!"

set "name=White"
set "code=0F"
if "!pick!"=="1" set "name=Blue"   & set "code=1F"
if "!pick!"=="2" set "name=Green"  & set "code=2F"
if "!pick!"=="3" set "name=Aqua"   & set "code=3F"
if "!pick!"=="4" set "name=Red"    & set "code=4F"
if "!pick!"=="5" set "name=Purple" & set "code=5F"
if "!pick!"=="6" set "name=Yellow" & set "code=6F"
if "!pick!"=="7" set "name=White"  & set "code=0F"

set "%cnVar%=!name!"
set "%ccVar%=!code!"
exit /b
