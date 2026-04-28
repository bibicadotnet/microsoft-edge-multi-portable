@echo off
setlocal
title Microsoft Defender Exclusion Tool

:: Automatically check and request Administrator rights
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%~dp0"
    set "currentDir=%~dp0"

    :: Define ANSI Escape Code for Yellow (ESC[33m) and Reset (ESC[0m)
    for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
    set "Yellow=%ESC%[33m"
    set "Reset=%ESC%[0m"

:menu
cls
echo ====================================================
echo         MICROSOFT DEFENDER EXCLUSION TOOL
echo ====================================================
:: Display the path in Yellow
echo  Current Directory: %Yellow%"%currentDir%"%Reset%
echo.
echo  1. Add current folder to Exclusion list
echo  2. Remove current folder from Exclusion list
echo  3. Exit
echo ====================================================
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" goto add_exclusion
if "%choice%"=="2" goto remove_exclusion
if "%choice%"=="3" exit
goto menu

:add_exclusion
echo Processing...
powershell -Command "Add-MpPreference -ExclusionPath '%currentDir%'"
if %errorlevel% equ 0 (
    echo [SUCCESS] Folder added to exclusions.
) else (
    echo [ERROR] Failed to add exclusion.
)
pause
goto menu

:remove_exclusion
echo Processing...
powershell -Command "Remove-MpPreference -ExclusionPath '%currentDir%'"
if %errorlevel% equ 0 (
    echo [SUCCESS] Folder removed from exclusions.
) else (
    echo [ERROR] Folder not found in list or access denied.
)
pause
goto menu
