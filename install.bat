@echo off
title Mini-Games Setup
cd /d "%~dp0"

echo ============================================
echo  Mini-Games - Windows Setup
echo ============================================
echo.

REM ---- Check Python ----
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not on your PATH.
    echo.
    echo Please download and install Python 3.9+ from:
    echo   https://www.python.org/downloads/
    echo.
    echo Make sure to check "Add Python to PATH" during installation.
    pause
    exit /b 1
)
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set pyver=%%i
echo [OK] Python %pyver% found

REM ---- Check pip ----
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] pip is not available.
    echo.
    echo Try running: python -m ensurepip --upgrade
    pause
    exit /b 1
)
echo [OK] pip found

REM ---- Install dependencies ----
echo.
echo Installing required packages from requirements.txt...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo.
    echo [WARN] pip install failed. If you see build errors, install the
    echo Microsoft C++ Build Tools from:
    echo   https://visualstudio.microsoft.com/visual-cpp-build-tools/
    echo then re-run this script.
    pause
    exit /b 1
)
echo [OK] Dependencies installed successfully

REM ---- Optional: Check for GNU Make ----
echo.
where make >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] GNU Make (make) not found. This is optional.
    echo        The project provides a Makefile, but you can also
    echo        run the games directly with:
    echo.
    echo          python WASD_Square.py
    echo          python spawning_circle.py
    echo.
    echo        To install Make via Chocolatey, run as Administrator:
    echo          choco install make
) else (
    echo [OK] GNU Make found
)

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
