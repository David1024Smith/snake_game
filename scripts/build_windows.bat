@echo off
echo ========================================
echo Snake Game - Windows Build Script
echo ========================================

:: Check if in the project root directory
if not exist "..\requirements.txt" (
    echo Error: Please run this script in the project root directory
    echo The current directory should contain requirements.txt file
    pause
    exit /b 1
)

:: Check if snake_game_full.py exists
if not exist "..\snake_game_full.py" (
    echo Error: snake_game_full.py not found
    echo Please make sure the main program file exists
    pause
    exit /b 1
)

:: Check icon file
if not exist "..\assets\images\icon.ico" (
    echo Warning: Icon file not found: assets\images\icon.ico
    echo Will use default icon
    set ICON_PARAM=
) else (
    echo Icon file found: ..\assets\images\icon.ico
    set ICON_PARAM=--icon="..\assets\images\icon.ico"
)

:: Check Python environment
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python environment not found, please install Python 3.8+
    pause
    exit /b 1
)

:: Create virtual environment
echo Creating virtual environment...
cd ..
if not exist "venv" (
    python -m venv venv
)

:: Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

:: Upgrade pip
echo Upgrading pip...
python -m pip install --upgrade pip

:: Install dependencies
echo Installing dependencies...
pip install -r requirements.txt

:: Create build directories
if not exist "build" mkdir build
if not exist "build\windows" mkdir build\windows
if not exist "build\temp" mkdir build\temp

:: Use PyInstaller to package
echo Starting to package the application...
pyinstaller --onefile ^
    --windowed ^
    --name "SnakeGame" ^
    %ICON_PARAM% ^
    --distpath "build\windows" ^
    --workpath "build\temp" ^
    --specpath "build" ^
    snake_game_full.py

if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

:: Copy resource files
echo Copying resource files...
if not exist "build\windows\src" mkdir "build\windows\src"
if not exist "build\windows\src\qml" mkdir "build\windows\src\qml"
if not exist "build\windows\assets" mkdir "build\windows\assets"

xcopy /E /I /Y "src\qml" "build\windows\src\qml"
xcopy /E /I /Y "assets" "build\windows\assets"
if exist "config.toml" copy /Y "config.toml" "build\windows\"

echo ========================================
echo Build completed!
echo Executable location: build\windows\SnakeGame.exe
echo ========================================
pause 