@echo off
setlocal enabledelayedexpansion
title Mini-Games Setup
cd /d "%~dp0"

echo ============================================
echo  Mini-Games - Windows Setup
echo ============================================
echo.

REM ---- Check / Install Python ----
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed.
    set /p "installpy=Download and install Python now? (Y/N): "
    if /i "!installpy!"=="Y" (
        where winget >nul 2>&1
        if !errorlevel! equ 0 (
            echo Installing Python via winget...
            winget install -e --id Python.Python --silent --accept-package-agreements
            if !errorlevel! equ 0 (
                echo [OK] Python installed via winget
                goto :python_installed
            )
            echo winget failed, trying direct download...
        )
        set pyver=3.13.3
        echo Downloading Python !pyver!...
        powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/!pyver!/python-!pyver!-amd64.exe' -OutFile '%TEMP%\python-installer.exe' -UseBasicParsing"
        if !errorlevel! neq 0 (
            echo [ERROR] Download failed. Check your internet connection.
            pause
            exit /b 1
        )
        echo Installing Python !pyver!...
        "%TEMP%\python-installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Shortcuts=0 Include_launcher=1
        set install_exit=!errorlevel!
        if !install_exit! neq 0 (
            if !install_exit! neq 1641 (
                echo [ERROR] Python installation failed (code: !install_exit!).
                pause
                exit /b 1
            )
        )
        echo [OK] Python !pyver! installed
    ) else (
        echo Aborted. Python is required.
        pause
        exit /b 1
    )
) else (
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do set pyver=%%i
    echo [OK] Python !pyver! found
)

:python_installed
REM Refresh PATH from registry
for /f "tokens=1,2,*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do if /i "%%a"=="Path" set systempath=%%c
if defined systempath set "PATH=!systempath!"
for /f "tokens=1,2,*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul') do if /i "%%a"=="Path" set userpath=%%c
if defined userpath set "PATH=!PATH!;!userpath!"

REM Search for python if still missing
python --version >nul 2>&1
if %errorlevel% neq 0 (
    for /d %%d in (
        "C:\Program Files\Python*"
        "C:\Program Files (x86)\Python*"
        "%LOCALAPPDATA%\Programs\Python\Python*"
    ) do if exist "%%d\python.exe" (
        set "PATH=%%d;%%d\Scripts;!PATH!"
    )
)

REM Verify python is accessible
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found after install. Restart your terminal and re-run.
    pause
    exit /b 1
)
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set pyver=%%i
echo [OK] Python !pyver! confirmed in PATH

REM ---- Ensure pip is available ----
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    python -m ensurepip --upgrade
)
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] pip could not be set up.
    pause
    exit /b 1
)
echo [OK] pip found

REM ---- Install Python dependencies ----
echo.
echo Installing required packages...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo [WARN] pip install failed. Trying without binary packages...
    pip install --no-binary :all: -r requirements.txt
    if !errorlevel! neq 0 (
        echo [ERROR] Could not install dependencies.
        echo You may need Microsoft C++ Build Tools:
        echo   https://visualstudio.microsoft.com/visual-cpp-build-tools/
        pause
        exit /b 1
    )
)
echo [OK] Dependencies installed

REM ---- Check / Install GNU Make ----
echo.
where make >nul 2>&1
if %errorlevel% neq 0 (
    echo GNU Make is not installed.
    set /p "installmake=Install Make via Chocolatey? (Y/N): "
    if /i "!installmake!"=="Y" (
        where choco >nul 2>&1
        if !errorlevel! neq 0 (
            echo Installing Chocolatey...
            powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
            if !errorlevel! neq 0 (
                echo [WARN] Chocolatey install failed. Skipping Make.
                goto :make_done
            )
            echo [OK] Chocolatey installed
        )
        choco install make -y
        if !errorlevel! equ 0 (
            echo [OK] GNU Make installed
        ) else (
            echo [WARN] Make install failed. Run games with python directly.
        )
    ) else (
        echo Skipping Make. Run games with: python WASD_Square.py
    )
) else (
    echo [OK] GNU Make found
)
:make_done

echo.
echo ============================================
echo  Setup complete!
echo.
echo  Run the games:
echo    python WASD_Square.py
echo    python spawning_circle.py
echo.
echo  Or with Make:
echo    make help
echo ============================================
pause
