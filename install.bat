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
    set /p "installpy=Download and install Python 3.13 now? (Y/N): "
    if /i "!installpy!"=="Y" (
        echo Downloading Python installer...
        powershell -Command "Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.13.3/python-3.13.3-amd64.exe -OutFile %TEMP%\python-installer.exe"
        echo Installing Python (this may take a moment)...
        start /wait "" "%TEMP%\python-installer.exe" /quiet InstallAllUsers=1 PrependPath=1
        if !errorlevel! neq 0 (
            echo [ERROR] Python installation failed.
            pause
            exit /b 1
        )
        echo [OK] Python installed
        REM Refresh PATH for the current session
        for /f "tokens=2 delims=:" %%a in ('path') do (
            set "path=%%a"
        )
        set "PATH=%PATH%;C:\Program Files\Python313;C:\Program Files\Python313\Scripts"
    ) else (
        echo Aborted. Python is required to run this project.
        pause
        exit /b 1
    )
) else (
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do set pyver=%%i
    echo [OK] Python !pyver! found
)

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
    echo [WARN] Standard install failed. Trying with --only-binary :all:...
    pip install --only-binary :all: -r requirements.txt
    if !errorlevel! neq 0 (
        echo [ERROR] Could not install dependencies.
        echo If you see build errors, install Microsoft C++ Build Tools from:
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
    set /p "installmake=Install Make via Chocolatey? (Y/N): "
    if /i "!installmake!"=="Y" (
        where choco >nul 2>&1
        if !errorlevel! neq 0 (
            echo Installing Chocolatey...
            powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" <nul
            if !errorlevel! neq 0 (
                echo [ERROR] Chocolatey installation failed.
                pause
                exit /b 1
            )
            echo [OK] Chocolatey installed
        )
        echo Installing GNU Make...
        choco install make -y
        if !errorlevel! neq 0 (
            echo [ERROR] Make installation failed.
            pause
            exit /b 1
        )
        echo [OK] GNU Make installed
    ) else (
        echo Skipping Make install. You can run games directly with python.
    )
) else (
    echo [OK] GNU Make found
)

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
