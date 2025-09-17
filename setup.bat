@echo off
chcp 65001 > nul
setlocal

rem Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    pause
    exit /b 1
)

rem Check if requirements.txt exists
if not exist requirements.txt (
    echo Error: requirements.txt not found
    pause
    exit /b 1
)

rem Remove existing venv directory if it exists
if exist venv (
    echo Removing existing venv directory...
    rmdir /s /q venv
)

rem Create virtual environment
echo Creating virtual environment...
python -m venv venv
if errorlevel 1 (
    echo Error creating virtual environment
    echo Try running the script as Administrator
    pause
    exit /b 1
)

rem Activate venv and install dependencies
echo Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo Error activating virtual environment
    pause
    exit /b 1
)

echo Installing packages from requirements.txt...
pip install --upgrade pip
pip install -r requirements.txt
if errorlevel 1 (
    echo Error installing packages
    pause
    exit /b 1
)

echo.
echo Virtual environment created successfully!
echo To activate it, run: venv\Scripts\activate.bat
echo.

pause