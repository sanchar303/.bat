@echo off
chcp 65001 > nul
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================
REM   ULTIMATE USER MANAGEMENT SYSTEM
REM   Version 3.0 - Professional Edition
REM ============================================

REM Initialize directories
if not exist "users" mkdir "users" >nul 2>&1
if not exist "bin" mkdir "bin" >nul 2>&1
if not exist "data" mkdir "data" >nul 2>&1
if not exist "logs" mkdir "logs" >nul 2>&1
if not exist "sessions" mkdir "sessions" >nul 2>&1

REM Check for welcome script
set "HAS_WELCOME_VBS=0"
if exist "data\welcome.vbs" set "HAS_WELCOME_VBS=1"

REM Global variables
set "currentUser="
set "welcomed=0"
set "VERSION=3.0 Pro"
set "loginAttempts=0"
set "maxAttempts=3"

REM ANSI escape init (for single-line progress bar)
set "ESC="
call :initAnsi

REM Initialize system
call :initSystem

REM ============================================
REM   SPLASH SCREEN
REM ============================================
:splash
color 0B
cls
echo.
echo.
echo.
echo                  ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
echo                  ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
echo                  ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
echo                  ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
echo                  ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
echo                  ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
echo.
echo                           User Management System v!VERSION!
echo.
echo                               Loading system components...
echo.

call :progressBar 150
timeout /t 1 >nul
goto menu


REM ============================================
REM   MAIN MENU
REM ============================================
:menu
title User Management System v!VERSION!
color 0B
cls
call :drawBorder
echo.
echo                         USER MANAGEMENT SYSTEM v!VERSION!
echo.
call :drawBorder
echo.
echo                          ┌─────────────────────────────┐
echo                          │   [1] Login to Account      │
echo                          │   [2] Create New Account    │
echo                          │   [3] View All Users        │
echo                          │   [4] System Statistics     │
echo                          │   [5] Activity Logs         │
echo                          │   [6] About System          │
echo                          │   [7] Exit System           │
echo                          └─────────────────────────────┘
echo.
call :drawBorder
echo.

choice /c 1234567 /n /m "     Select an option (1-7): "
set "menuChoice=!errorlevel!"

if "!menuChoice!"=="1" goto login
if "!menuChoice!"=="2" goto signup
if "!menuChoice!"=="3" goto listUsers
if "!menuChoice!"=="4" goto statistics
if "!menuChoice!"=="5" goto viewLogs
if "!menuChoice!"=="6" goto about
if "!menuChoice!"=="7" goto exitSystem

goto menu


REM ============================================
REM   LOGIN SECTION
REM ============================================
:login
set "loginAttempts=0"

:loginPrompt
title Login - User Management System
color 0E
cls
call :drawBorder
echo.
echo                                    LOGIN
echo.
call :drawBorder
echo.

if !loginAttempts! GTR 0 (
    echo     [!] Failed attempts: !loginAttempts!/!maxAttempts!
    echo.
)

set "username="
set /p "username=     Username: "
call :trim username

if "!username!"=="" (
    echo.
    echo     [!] Username cannot be empty.
    call :pressKey
    goto loginPrompt
)

call :validateUsername "!username!"
if errorlevel 1 (
    echo.
    echo     [!] Invalid username format.
    echo     [i] Rules: 3-20 characters, letters, numbers, _ and - only
    call :pressKey
    goto loginPrompt
)

set "userFile=users\!username!.ini"
if not exist "!userFile!" (
    echo.
    echo     [!] Username not found.
    echo.
    choice /c YN /n /m "     Would you like to create this account? (Y/N): "
    if !errorlevel!==1 (
        set "signupUsername=!username!"
        goto signupWithUser
    )
    goto loginPrompt
)

set "password="
set /p "password=     Password: "

if "!password!"=="" (
    echo.
    echo     [!] Password cannot be empty.
    call :pressKey
    goto loginPrompt
)

call :validatePassword "!password!"
if errorlevel 1 (
    echo.
    echo     [!] Invalid password format.
    call :pressKey
    goto loginPrompt
)

call :readValue "!userFile!" "password" storedPass

if "!storedPass!"=="" (
    echo.
    echo     [!] Account data corrupted. Please contact administrator.
    call :log "ERROR" "Corrupted account data for user: !username!"
    call :pressKey
    goto menu
)

if "!password!"=="!storedPass!" (
    set "currentUser=!username!"
    set "welcomed=0"
    set "password="
    set "loginAttempts=0"
    echo.
    echo     [✓] Login successful! Welcome back, !username!
    call :log "LOGIN" "User !username! logged in successfully"
    call :updateLastLogin "!userFile!"
    call :incrementLogins "!userFile!"
    call :progressBar 30
    goto profile
) else (
    set "password="
    set /a loginAttempts+=1
    echo.
    echo     [!] Incorrect password. Please try again.
    call :log "WARNING" "Failed login attempt for user: !username!"
    
    if !loginAttempts! GEQ !maxAttempts! (
        echo.
        echo     [!] Maximum login attempts reached. Returning to menu.
        call :log "SECURITY" "Max login attempts reached for user: !username!"
        timeout /t 3 >nul
        goto menu
    )
    
    call :pressKey
    goto loginPrompt
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
call :drawBorder
echo.
echo                                   SIGNUP
echo.
call :drawBorder
echo.

if defined signupUsername (
    set "username=!signupUsername!"
    echo     [i] Creating account for: !signupUsername!
    echo.
) else (
    set "username="
    set /p "username=     Choose a username: "
    call :trim username
    
    if "!username!"=="" (
        echo.
        echo     [!] Username cannot be empty.
        call :pressKey
        goto signup
    )
)

call :validateUsername "!username!"
if errorlevel 1 (
    echo.
    echo     [!] Invalid username format.
    echo     [i] Rules: 3-20 characters, letters, numbers, _ and - only
    call :pressKey
    set "signupUsername="
    goto signup
)

set "userFile=users\!username!.ini"
if exist "!userFile!" (
    echo.
    echo     [!] Username already exists. Please choose another.
    call :pressKey
    set "signupUsername="
    goto signup
)

set "password="
set /p "password=     Choose a password: "

if "!password!"=="" (
    echo.
    echo     [!] Password cannot be empty.
    call :pressKey
    goto signupWithUser
)

call :validatePassword "!password!"
if errorlevel 1 (
    echo.
    echo     [!] Invalid password format.
    echo     [i] Rules: 4-30 characters, letters, numbers, _ - @ # . only
    call :pressKey
    goto signupWithUser
)

REM Password strength check
call :checkPasswordStrength "!password!" strength
echo.
echo     [i] Password strength: !strength!
timeout /t 1 >nul

set "email="
set "phone="
set "fullname="
set /p "fullname=     Full name (optional): "
set /p "email=     Email (optional): "
set /p "phone=     Phone (optional): "

call :getTimestamp createdAt
call :pickColor colorName colorCode

> "!userFile!" (
    echo username=!username!
    echo password=!password!
    echo fullname=!fullname!
    echo email=!email!
    echo phone=!phone!
    echo created=!createdAt!
    echo lastlogin=Never
    echo logincount=0
    echo colorname=!colorName!
    echo colorcode=!colorCode!
    echo status=Active
)

set "password="
set "signupUsername="
echo.
echo     [✓] Account created successfully!
echo     [i] Initializing your profile...
call :log "SIGNUP" "New user registered: !username!"
call :progressBar 50
echo.
echo     [i] You can now login with your credentials.
call :pressKey
goto menu


REM ============================================
REM   LIST USERS
REM ============================================
:listUsers
title User Directory - User Management System
color 0D
cls
call :drawBorder
echo.
echo                                USER DIRECTORY
echo.
call :drawBorder
echo.

set "found=0"
set "count=0"

echo     ┌────┬─────────────────────┬──────────────┬─────────────────────┐
echo     │ No │ Username            │ Status       │ Last Login          │
echo     ├────┼─────────────────────┼──────────────┼─────────────────────┤

for %%F in ("users\*.ini") do (
    set "found=1"
    set /a count+=1
    set "user=%%~nF"
    call :readValue "%%F" "status" userStatus
    call :readValue "%%F" "lastlogin" lastLogin
    
    if "!userStatus!"=="" set "userStatus=Active"
    if "!lastLogin!"=="" set "lastLogin=Never"
    
    set "numPad=!count!   "
    set "userPad=!user!                     "
    set "statusPad=!userStatus!              "
    set "loginPad=!lastLogin!                     "
    
    echo     │ !numPad:~0,2! │ !userPad:~0,19! │ !statusPad:~0,12! │ !loginPad:~0,19! │
)

if "!found!"=="0" (
    echo     │    │ No users registered │              │                     │
)

echo     └────┴─────────────────────┴──────────────┴─────────────────────┘
echo.
echo     Total Users: !count!
echo.
call :drawBorder
echo.
echo     Press any key to return to main menu...
pause >nul
goto menu


REM ============================================
REM   STATISTICS
REM ============================================
:statistics
title System Statistics - User Management System
color 0C
cls
call :drawBorder
echo.
echo                             SYSTEM STATISTICS
echo.
call :drawBorder
echo.

set "totalUsers=0"
set "activeUsers=0"
set "totalLogins=0"

for %%F in ("users\*.ini") do (
    set /a totalUsers+=1
    call :readValue "%%F" "status" stat
    call :readValue "%%F" "logincount" lc
    if "!stat!"=="Active" set /a activeUsers+=1
    if not "!lc!"=="" set /a totalLogins+=!lc!
)

set "deletedUsers=0"
for %%F in ("bin\*.ini") do set /a deletedUsers+=1

call :getLogCount logCount

echo     ┌──────────────────────────────────────────────┐
echo     │  Total Registered Users    :  !totalUsers!              │
echo     │  Active Users              :  !activeUsers!              │
echo     │  Deleted Users (in bin)    :  !deletedUsers!              │
echo     │  Total Login Sessions      :  !totalLogins!            │
echo     │  System Log Entries        :  !logCount!            │
echo     └──────────────────────────────────────────────┘
echo.

set "maxLogins=0"
set "topUser=None"
for %%F in ("users\*.ini") do (
    call :readValue "%%F" "logincount" lc
    call :readValue "%%F" "username" un
    if not "!lc!"=="" (
        if !lc! GTR !maxLogins! (
            set "maxLogins=!lc!"
            set "topUser=!un!"
        )
    )
)

echo     ┌──────────────────────────────────────────────┐
echo     │  Most Active User          :  !topUser!       │
echo     │  Total Logins              :  !maxLogins!             │
echo     └──────────────────────────────────────────────┘
echo.

call :drawBorder
echo.
echo     Press any key to return to main menu...
pause >nul
goto menu


REM ============================================
REM   VIEW LOGS
REM ============================================
:viewLogs
title Activity Logs - User Management System
color 06
cls
call :drawBorder
echo.
echo                              ACTIVITY LOGS
echo.
call :drawBorder
echo.

if not exist "logs\activity.log" (
    echo     [i] No activity logs found.
    echo.
    call :drawBorder
    echo.
    echo     Press any key to return to main menu...
    pause >nul
    goto menu
)

echo     [i] Showing last 20 entries:
echo.

set "lineCount=0"
for /f "usebackq delims=" %%L in ("logs\activity.log") do (
    set /a lineCount+=1
)

if !lineCount! LEQ 20 (
    type "logs\activity.log"
) else (
    set /a skipLines=!lineCount!-20
    more +!skipLines! "logs\activity.log"
)

echo.
call :drawBorder
echo.
echo     [1] View full log in Notepad
echo     [2] Clear logs
echo     [3] Return to menu
echo.

choice /c 123 /n /m "     Select option: "
set "logChoice=!errorlevel!"

if "!logChoice!"=="1" (
    start "" notepad "logs\activity.log"
    goto viewLogs
)
if "!logChoice!"=="2" (
    echo.
    choice /c YN /n /m "     Are you sure you want to clear all logs? (Y/N): "
    if !errorlevel!==1 (
        break > "logs\activity.log"
        echo.
        echo     [✓] Logs cleared successfully.
        call :log "SYSTEM" "Activity logs cleared"
        timeout /t 2 >nul
    )
    goto viewLogs
)
goto menu


REM ============================================
REM   ABOUT
REM ============================================
:about
title About - User Management System
color 0B
cls
call :drawBorder
echo.
echo                                  ABOUT
echo.
call :drawBorder
echo.
echo     ┌──────────────────────────────────────────────┐
echo     │  System Name    :  User Management System    │
echo     │  Version        :  !VERSION!                   │
echo     │  Build Date     :  2026-01-31                │
echo     │  Platform       :  Windows Batch Script      │
echo     └──────────────────────────────────────────────┘
echo.
echo     Features:
echo       • Secure user authentication
echo       • Profile management with customization
echo       • Activity logging and statistics
echo       • Password strength validation
echo       • Session tracking
echo       • User data backup (bin folder)
echo       • Custom color themes
echo       • Login attempt limiting
echo.
echo     Developer: Professional Edition Team
echo.
call :drawBorder
echo.
echo     Press any key to return to main menu...
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
    echo     [!] Profile file missing or corrupted.
    call :pressKey
    goto menu
)

call :readValue "!userFile!" "username"    u
call :readValue "!userFile!" "fullname"    fn
call :readValue "!userFile!" "email"       e
call :readValue "!userFile!" "phone"       p
call :readValue "!userFile!" "created"     c
call :readValue "!userFile!" "lastlogin"   ll
call :readValue "!userFile!" "logincount"  lc
call :readValue "!userFile!" "colorname"   cn
call :readValue "!userFile!" "colorcode"   cc
call :readValue "!userFile!" "status"      st

if "!cc!"=="" set "cc=0B"
if "!st!"=="" set "st=Active"
if "!lc!"=="" set "lc=0"
if "!fn!"=="" set "fn=Not set"

color !cc!

if "!welcomed!"=="0" (
    if "!HAS_WELCOME_VBS!"=="1" (
        cscript //nologo "data\welcome.vbs" "!currentUser!" >nul 2>&1
    )
    set "welcomed=1"
)

title Profile: !u! - User Management System
cls
call :drawBorder
echo.
echo                                USER PROFILE
echo.
call :drawBorder
echo.
echo     ┌──────────────────────────────────────────────────────────┐
echo     │  Username        :  !u!
echo     │  Full Name       :  !fn!
echo     │  Password        :  ••••••••
echo     │  Email           :  !e!
echo     │  Phone           :  !p!
echo     │  Account Status  :  !st!
echo     │  Theme Color     :  !cn!
echo     │  Created         :  !c!
echo     │  Last Login      :  !ll!
echo     │  Total Logins    :  !lc!
echo     └──────────────────────────────────────────────────────────┘
echo.
call :drawBorder
echo.
echo     ┌────────────────────────────────────────┐
echo     │  [1] Refresh Profile                   │
echo     │  [2] Change Password                   │
echo     │  [3] Update Email                      │
echo     │  [4] Update Phone                      │
echo     │  [5] Update Full Name                  │
echo     │  [6] Change Username                   │
echo     │  [7] Change Theme Color                │
echo     │  [8] Edit Profile (Notepad)            │
echo     │  [9] Export Profile Data               │
echo     │  [A] Delete Account                    │
echo     │  [B] Logout                            │
echo     └────────────────────────────────────────┘
echo.
call :drawBorder
echo.

choice /c 123456789AB /n /m "     Select an option: "
set "profileChoice=!errorlevel!"

if "!profileChoice!"=="1" goto profile
if "!profileChoice!"=="2" goto changePassword
if "!profileChoice!"=="3" goto changeEmail
if "!profileChoice!"=="4" goto changePhone
if "!profileChoice!"=="5" goto changeFullName
if "!profileChoice!"=="6" goto changeUsername
if "!profileChoice!"=="7" goto changeColor
if "!profileChoice!"=="8" goto editProfile
if "!profileChoice!"=="9" goto exportProfile
if "!profileChoice!"=="10" goto deleteAccount
if "!profileChoice!"=="11" goto logout

goto profile


REM ============================================
REM   EXPORT PROFILE
REM ============================================
:exportProfile
title Export Profile - !currentUser!
echo.
echo     [i] Exporting profile data...

set "exportFile=data\!currentUser!_export.txt"
call :getTimestamp exportTime

> "!exportFile!" (
    echo ================================================
    echo   PROFILE DATA EXPORT
    echo   User: !currentUser!
    echo   Export Date: !exportTime!
    echo ================================================
    echo.
    type "!userFile!"
    echo.
    echo ================================================
)

echo     [✓] Profile exported to: !exportFile!
call :log "EXPORT" "User !currentUser! exported profile data"
start "" notepad "!exportFile!"
call :pressKey
goto profile


REM ============================================
REM   EDIT PROFILE IN NOTEPAD
REM ============================================
:editProfile
title Editing Profile - !currentUser!
echo.
echo     [i] Opening profile in Notepad...
echo     [!] Warning: Manual editing may cause data corruption.
call :log "EDIT" "User !currentUser! opened profile for manual editing"
start "" /wait notepad "!userFile!"
goto profile


REM ============================================
REM   CHANGE PASSWORD
REM ============================================
:changePassword
title Change Password - !currentUser!
cls
call :drawBorder
echo.
echo                             CHANGE PASSWORD
echo.
call :drawBorder
echo.

set "oldPass="
set /p "oldPass=     Current password: "

if "!oldPass!"=="" (
    echo.
    echo     [i] Operation cancelled.
    call :pressKey
    goto profile
)

call :readValue "!userFile!" "password" storedPass

if not "!oldPass!"=="!storedPass!" (
    echo.
    echo     [!] Current password is incorrect.
    call :log "SECURITY" "Failed password change attempt for user: !currentUser!"
    call :pressKey
    goto profile
)

set "newPass="
set /p "newPass=     New password: "

if "!newPass!"=="" (
    echo.
    echo     [i] Operation cancelled.
    call :pressKey
    goto profile
)

call :validatePassword "!newPass!"
if errorlevel 1 (
    echo.
    echo     [!] Invalid password format.
    echo     [i] Rules: 4-30 characters, letters, numbers, _ - @ # . only
    call :pressKey
    goto profile
)

call :checkPasswordStrength "!newPass!" strength
echo.
echo     [i] Password strength: !strength!

call :writeValue "!userFile!" "password" "!newPass!"
echo     [✓] Password updated successfully!
call :log "UPDATE" "User !currentUser! changed password"
call :pressKey
goto profile


REM ============================================
REM   CHANGE EMAIL
REM ============================================
:changeEmail
title Change Email - !currentUser!
cls
call :drawBorder
echo.
echo                               CHANGE EMAIL
echo.
call :drawBorder
echo.

set "newEmail="
set /p "newEmail=     New email: "

if "!newEmail!"=="" (
    echo.
    echo     [i] Operation cancelled.
    call :pressKey
    goto profile
)

call :writeValue "!userFile!" "email" "!newEmail!"
echo.
echo     [✓] Email updated successfully!
call :log "UPDATE" "User !currentUser! updated email"
call :pressKey
goto profile


REM ============================================
REM   CHANGE PHONE
REM ============================================
:changePhone
title Change Phone - !currentUser!
cls
call :drawBorder
echo.
echo                               CHANGE PHONE
echo.
call :drawBorder
echo.

set "newPhone="
set /p "newPhone=     New phone: "

if "!newPhone!"=="" (
    echo.
    echo     [i] Operation cancelled.
    call :pressKey
    goto profile
)

call :writeValue "!userFile!" "phone" "!newPhone!"
echo.
echo     [✓] Phone updated successfully!
call :log "UPDATE" "User !currentUser! updated phone"
call :pressKey
goto profile


REM ============================================
REM   CHANGE FULL NAME
REM ============================================
:changeFullName
title Change Full Name - !currentUser!
cls
call :drawBorder
echo.
echo                             CHANGE FULL NAME
echo.
call :drawBorder
echo.

set "newName="
set /p "newName=     New full name: "

if "!newName!"=="" (
    echo.
    echo     [i] Operation cancelled.
    call :pressKey
    goto profile
)

call :writeValue "!userFile!" "fullname" "!newName!"
echo.
echo     [✓] Full name updated successfully!
call :log "UPDATE" "User !currentUser! updated full name"
call :pressKey
goto profile


REM ============================================
REM   CHANGE USERNAME
REM ============================================
:changeUsername
title Change Username - !currentUser!
cls
call :drawBorder
echo.
echo                             CHANGE USERNAME
echo.
call :drawBorder
echo.

set "newUser="
set /p "newUser=     New username: "
call :trim newUser

if "!newUser!"=="" (
    echo.
    echo     [i] Operation cancelled.
    call :pressKey
    goto profile
)

call :validateUsername "!newUser!"
if errorlevel 1 (
    echo.
    echo     [!] Invalid username format.
    echo     [i] Rules: 3-20 characters, letters, numbers, _ and - only
    call :pressKey
    goto profile
)

if exist "users\!newUser!.ini" (
    echo.
    echo     [!] Username already exists. Please choose another.
    call :pressKey
    goto profile
)

ren "!userFile!" "!newUser!.ini" >nul 2>&1
call :log "UPDATE" "User !currentUser! changed username to !newUser!"
set "currentUser=!newUser!"
set "userFile=users\!currentUser!.ini"
call :writeValue "!userFile!" "username" "!currentUser!"

echo.
echo     [✓] Username updated successfully!
call :pressKey
goto profile


REM ============================================
REM   CHANGE COLOR
REM ============================================
:changeColor
title Change Theme Color - !currentUser!
cls
call :drawBorder
echo.
echo                            CHANGE THEME COLOR
echo.
call :drawBorder
echo.

call :pickColor newColorName newColorCode
call :writeValue "!userFile!" "colorname" "!newColorName!"
call :writeValue "!userFile!" "colorcode" "!newColorCode!"

echo.
echo     [✓] Theme color updated to !newColorName!!
call :log "UPDATE" "User !currentUser! changed theme color to !newColorName!"
call :pressKey
goto profile


REM ============================================
REM   DELETE ACCOUNT
REM ============================================
:deleteAccount
title Delete Account - !currentUser!
cls
call :drawBorder
echo.
echo                              DELETE ACCOUNT
echo.
call :drawBorder
echo.
echo     [WARNING] This will move your account to the bin folder.
echo     [WARNING] This action cannot be easily undone.
echo     [WARNING] All your data will be archived.
echo.

choice /c YN /n /m "     Are you sure you want to delete your account? (Y/N): "

if !errorlevel!==2 (
    echo.
    echo     [i] Account deletion cancelled.
    call :pressKey
    goto profile
)

echo.
echo     [!] FINAL WARNING: Your account will be deleted!
echo.
choice /c YN /n /m "     Type Y to confirm deletion, N to cancel: "

if !errorlevel!==2 (
    echo.
    echo     [i] Account deletion cancelled.
    call :pressKey
    goto profile
)

call :writeValue "!userFile!" "status" "Deleted"
call :getTimestamp deleteTime
call :writeValue "!userFile!" "deletedon" "!deleteTime!"

move /Y "!userFile!" "bin\!currentUser!.ini" >nul 2>&1
echo.
echo     [✓] Account deleted successfully.
echo     [i] Your data has been moved to the bin folder.
call :log "DELETE" "User !currentUser! deleted their account"
timeout /t 3 >nul
set "currentUser="
set "welcomed=0"
goto menu


REM ============================================
REM   LOGOUT
REM ============================================
:logout
echo.
echo     [i] Logging out...
call :log "LOGOUT" "User !currentUser! logged out"
timeout /t 1 >nul
set "currentUser="
set "welcomed=0"
color 0B
goto menu


REM ============================================
REM   EXIT SYSTEM
REM ============================================
:exitSystem
call :log "SYSTEM" "System shutdown initiated"
color 0C
cls
call :drawBorder
echo.
echo                        Thank you for using our system!
echo.
call :drawBorder
echo.
echo                            Shutting down system...
echo.
call :progressBar 50
echo.
echo                                  Goodbye!
echo.
timeout /t 2 >nul
color
exit /b 0


REM ============================================
REM   HELPER FUNCTIONS
REM ============================================

:initAnsi
for /f "delims=" %%E in ('echo prompt $E^| cmd') do set "ESC=%%E"
exit /b


:initSystem
if not exist "logs\activity.log" (
    break > "logs\activity.log"
    call :log "SYSTEM" "System initialized"
)
exit /b


:log
set "logType=%~1"
set "logMsg=%~2"
call :getTimestamp logTime
>> "logs\activity.log" echo [!logTime!] [!logType!] !logMsg!
exit /b


:getLogCount
set "%~1=0"
if exist "logs\activity.log" (
    for /f %%A in ('type "logs\activity.log" ^| find /c /v ""') do set "%~1=%%A"
)
exit /b


:updateLastLogin
call :getTimestamp loginTime
call :writeValue "%~1" "lastlogin" "!loginTime!"
exit /b


:incrementLogins
call :readValue "%~1" "logincount" currentCount
if "!currentCount!"=="" set "currentCount=0"
set /a newCount=!currentCount!+1
call :writeValue "%~1" "logincount" "!newCount!"
exit /b


:checkPasswordStrength
REM FIXED length counter
setlocal EnableDelayedExpansion
set "pwd=%~1"
set "len=0"
:lenLoop
if not defined pwd goto lenDone
set "pwd=!pwd:~1!"
set /a len+=1
goto lenLoop
:lenDone
if !len! LSS 6  (endlocal & set "%~2=Weak" & exit /b)
if !len! LSS 10 (endlocal & set "%~2=Medium" & exit /b)
endlocal & set "%~2=Strong"
exit /b


:progressBar
REM FIXED: single-line updating progress bar (no screen spam)
setlocal EnableDelayedExpansion
set "total=%~1"
set "current=0"
set "width=30"

REM Initial render
set "bars=0"
set "remaining=%width%"
set "bar="
for /l %%i in (1,1,%width%) do set "space=!space! "
<nul set /p "=%ESC%[2K     Progress: [!space!] 0%%"

:progressLoop
if !current! GEQ !total! goto progressDone

set /a current+=1
set /a percent=current*100/total
set /a bars=current*width/total
set /a remaining=width-bars

set "bar="
for /l %%i in (1,1,!bars!) do set "bar=!bar!█"
set "space="
for /l %%i in (1,1,!remaining!) do set "space=!space! "

<nul set /p "=%ESC%[1G%ESC%[2K     Progress: [!bar!!space!] !percent!%%"
goto progressLoop

:progressDone
<nul set /p "=%ESC%[1G%ESC%[2K     Progress: [██████████████████████████████] 100%%"
echo.
endlocal
exit /b


:drawBorder
echo     ================================================================
exit /b


:pressKey
echo.
echo     Press any key to continue...
pause >nul
exit /b


:trim
set "var=%~1"
call set "str=%%%var%%%"
for /f "tokens=* delims= " %%A in ("!str!") do set "%var%=%%A"
exit /b


:validateUsername
setlocal
set "u=%~1"
if "!u!"=="" (endlocal & exit /b 1)
if "!u:~2,1!"=="" (endlocal & exit /b 1)
if not "!u:~20,1!"=="" (endlocal & exit /b 1)
echo(!u!| findstr /r "^[A-Za-z0-9_-][A-Za-z0-9_-]*$" >nul
if errorlevel 1 (endlocal & exit /b 1)
endlocal & exit /b 0


:validatePassword
setlocal
set "p=%~1"
if "!p!"=="" (endlocal & exit /b 1)
if "!p:~3,1!"=="" (endlocal & exit /b 1)
if not "!p:~30,1!"=="" (endlocal & exit /b 1)
echo(!p!| findstr /r "^[A-Za-z0-9_@#\.-][A-Za-z0-9_@#\.-]*$" >nul
if errorlevel 1 (endlocal & exit /b 1)
endlocal & exit /b 0


:getTimestamp
set "%~1=!date! !time!"
exit /b


:readValue
REM FIXED: proper output variable assignment
set "file=%~1"
set "key=%~2"
set "outVar=%~3"
set "%outVar%="
for /f "usebackq tokens=1* delims==" %%A in (`findstr /i /b "%key%=" "%file%" 2^>nul`) do (
    call set "%outVar%=%%B"
    goto :eof
)
exit /b


:writeValue
setlocal
set "file=%~1"
set "key=%~2"
set "value=%~3"
set "tmp=%temp%\usr_!random!!random!.tmp"
set "found=0"

break > "!tmp!"

for /f "usebackq delims=" %%L in ("%file%") do (
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
set "cnVar=%~1"
set "ccVar=%~2"

echo.
echo     Choose your theme color:
echo.
echo     ┌────────────────────────────────┐
echo     │  [1] Blue      (Professional)  │
echo     │  [2] Green     (Fresh)         │
echo     │  [3] Aqua      (Cool)          │
echo     │  [4] Red       (Bold)          │
echo     │  [5] Purple    (Creative)      │
echo     │  [6] Yellow    (Bright)        │
echo     │  [7] White     (Classic)       │
echo     │  [8] Dark Blue (Elite)         │
echo     │  [9] Pink      (Modern)        │
echo     └────────────────────────────────┘
echo.

choice /c 123456789 /n /m "     Select a color (1-9): "
set "pick=!errorlevel!"

set "name=White"
set "code=0F"
if "!pick!"=="1" set "name=Blue"      & set "code=1F"
if "!pick!"=="2" set "name=Green"     & set "code=2F"
if "!pick!"=="3" set "name=Aqua"      & set "code=3F"
if "!pick!"=="4" set "name=Red"       & set "code=4F"
if "!pick!"=="5" set "name=Purple"    & set "code=5F"
if "!pick!"=="6" set "name=Yellow"    & set "code=6F"
if "!pick!"=="7" set "name=White"     & set "code=0F"
if "!pick!"=="8" set "name=Dark Blue" & set "code=1E"
if "!pick!"=="9" set "name=Pink"      & set "code=0D"

set "%cnVar%=!name!"
set "%ccVar%=!code!"
exit /b
