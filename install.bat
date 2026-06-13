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
        REM Try winget first (built into Windows 10/11)
        where winget >nul 2>&1
        if !errorlevel! equ 0 (
            echo Installing Python via winget...
            winget install -e --id Python.Python --silent --accept-package-agreements
            if !errorlevel! equ 0 (
                echo [OK] Python installed via winget
                goto :python_installed
            )
            echo winget install failed, trying direct download...
        )

        REM Fallback: direct download of latest Python
        echo Detecting latest Python version...
        for /f "delims=" %%v in ('powershell -NoProfile -Command "(Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/' -UseBasicParsing).Links.href | Select-String '^\d+\.\d+\.\d+/$' | Select-Object -Last 1"') do set pyver=%%v
        set pyver=!pyver:/=!
        if "!pyver!"=="" set pyver=3.13.3
        echo Downloading Python !pyver!...
        powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/!pyver!/python-!pyver!-amd64.exe' -OutFile '%TEMP%\python-installer.exe' -UseBasicParsing"
        if !errorlevel! neq 0 (
            echo [ERROR] Download failed. Check your internet connection.
            pause
            exit /b 1
        )
        echo Installing Python !pyver! (this may take a moment)...
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
        echo Aborted. Python is required to run this project.
        pause
        exit /b 1
    )
) else (
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do set pyver=%%i
    echo [OK] Python !pyver! found
)

:python_installed
REM Refresh PATH for current session
echo Refreshing PATH...
for /f "tokens=1,2,*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do if /i "%%a"=="Path" set "systempath=%%c"
if defined systempath set "PATH=!systempath!"
for /f "tokens=1,2,*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul') do if /i "%%a"=="Path" set "userpath=%%c"
if defined userpath set "PATH=!PATH!;!userpath!"

REM Try to find python if still not in PATH
python --version >nul 2>&1
if %errorlevel% neq 0 (
    for /d %%d in ("C:\Program Files\Python*" "C:\Program Files (x86)\Python*" "%LOCALAPPDATA%\Programs\Python\Python*") do (
        if exist "%%d\python.exe" (
            set "PYTHON_DIR=%%d"
            set "PATH=!PYTHON_DIR!;!PYTHON_DIR!\Scripts;!PATH!"
        )
    )
)

REM Final Python check
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python still not found after install. You may need to restart your terminal.
    pause
    exit /b 1
)
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set pyver=%%i
echo [OK] Python !pyver! confirmed in PATH

REM ---- Ensure pip is available ----
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    python -m ensurepip --upgrade >nul 2>&1
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
        echo You may need to install Microsoft C++ Build Tools:
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
    echo GNU Make (make) is not installed.
    set /p "installmake=Install Make via Chocolatey now? (Y/N): "
    if /i "!installmake!"=="Y" (
        where choco >nul 2>&1
        if !errorlevel! neq 0 (
            echo Installing Chocolatey...
            powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
            if !errorlevel! neq 0 (
                echo [ERROR] Chocolatey installation failed.
                echo You can skip Make and run games directly with: python WASD_Square.py
                goto :make_done
            )
            echo [OK] Chocolatey installed
        )
        echo Installing GNU Make via Chocolatey...
        choco install make -y
        if !errorlevel! neq 0 (
            echo [ERROR] Make installation failed.
            echo You can skip Make and run games directly with: python WASD_Square.py
        ) else (
            echo [OK] GNU Make installed via Chocolatey
        )
    ) else (
        echo Skipping Make install. You can run games directly with python.
    )
) else (
    echo [OK] GNU Make found
)
:make_done

REM ---- Done ----
echo.
echo ============================================
echo  Setup complete!
echo.
echo  To run the games:
echo    python WASD_Square.py
echo    python spawning_circle.py
echo.
echo  Or with Make:
echo    make help
echo ============================================
pause
