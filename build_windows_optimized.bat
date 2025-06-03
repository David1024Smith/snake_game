@echo off
echo ========================================
echo Snake Game - Windows Build Script (Fixed Version)
echo ========================================

:: Enable delayed expansion for better variable handling
setlocal enabledelayedexpansion

:: Detect current directory and set project root
if exist "requirements.txt" if exist "src" (
    :: Running from project root
    set PROJECT_ROOT=%cd%
    echo Running from project root directory
) else if exist "..\requirements.txt" if exist "..\src" (
    :: Running from scripts directory
    set PROJECT_ROOT=%cd%\..
    echo Running from scripts directory
) else (
    echo Error: Please run this script from either:
    echo   1. Project root directory ^(containing requirements.txt^)
    echo   2. Scripts directory ^(scripts/^)
    pause
    exit /b 1
)

:: Check main program file (support multiple possible locations)
set MAIN_FILE=
if exist "%PROJECT_ROOT%\src\python\main.py" (
    set MAIN_FILE=%PROJECT_ROOT%\src\python\main.py
    echo Found main file: src\python\main.py
) else if exist "%PROJECT_ROOT%\snake_game_full.py" (
    set MAIN_FILE=%PROJECT_ROOT%\snake_game_full.py
    echo Found main file: snake_game_full.py
) else if exist "%PROJECT_ROOT%\main.py" (
    set MAIN_FILE=%PROJECT_ROOT%\main.py
    echo Found main file: main.py
) else (
    echo Error: Main program file not found. Searched for:
    echo   - src\python\main.py
    echo   - snake_game_full.py
    echo   - main.py
    pause
    exit /b 1
)

:: Check Python environment with detailed diagnostics
echo Checking Python environment...
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python environment not found, please install Python 3.8+
    echo Trying python3 command...
    python3 --version >nul 2>&1
    if errorlevel 1 (
        echo Error: Neither python nor python3 command found
        echo Please install Python and add it to your PATH
        pause
        exit /b 1
    ) else (
        set PYTHON_CMD=python3
        echo Using python3 command
    )
) else (
    set PYTHON_CMD=python
    !PYTHON_CMD! --version
)

:: Move to project root directory  
echo Changing to project root: !PROJECT_ROOT!
cd /d "!PROJECT_ROOT!"

:: Enhanced virtual environment handling
echo Creating/checking virtual environment...
set VENV_ACTIVATED=0

:: Try to use existing virtual environment first
if exist "venv\Scripts\activate.bat" (
    echo Found existing virtual environment, attempting activation...
    call venv\Scripts\activate.bat >nul 2>&1
    if errorlevel 0 (
        echo Virtual environment activated successfully
        set VENV_ACTIVATED=1
    ) else (
        echo Warning: Failed to activate existing virtual environment
        echo Recreating virtual environment...
        rmdir /s /q venv 2>nul
    )
)

:: Create new virtual environment if needed
if !VENV_ACTIVATED! EQU 0 (
    echo Creating new virtual environment...
    !PYTHON_CMD! -m venv venv
    if errorlevel 1 (
        echo Error: Failed to create virtual environment
        echo Continuing with system Python environment...
        set USE_SYSTEM_PYTHON=1
    ) else (
        echo Activating new virtual environment...
        call venv\Scripts\activate.bat >nul 2>&1
        if errorlevel 0 (
            echo Virtual environment activated successfully
            set VENV_ACTIVATED=1
        ) else (
            echo Warning: Failed to activate virtual environment
            echo Continuing with system Python environment...
            set USE_SYSTEM_PYTHON=1
        )
    )
)

:: Upgrade pip with error handling
echo Upgrading pip...
python -m pip install --upgrade pip --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org
if errorlevel 1 (
    echo Warning: pip upgrade failed, continuing with current version...
)

:: Install dependencies with enhanced error handling
echo Installing dependencies...
pip install -r requirements.txt --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org
if errorlevel 1 (
    echo Error: Failed to install dependencies
    echo Please check your internet connection and try again
    pause
    exit /b 1
)

:: Create build directories
echo Creating build directories...
if not exist "build" mkdir build
if not exist "build\windows_optimized" mkdir build\windows_optimized  
if not exist "build\temp_optimized" mkdir build\temp_optimized

:: Verify required directories exist
echo Verifying required files and directories...
if not exist "src\qml" (
    echo Error: src\qml directory not found
    pause
    exit /b 1
)
if not exist "assets" (
    echo Error: assets directory not found  
    pause
    exit /b 1
)
if not exist "config.toml" (
    echo Error: config.toml file not found
    pause
    exit /b 1
)

:: ===== Simplified Icon Processing Section =====
set ICON_PATH=!PROJECT_ROOT!\assets\images\icon.ico
set ICON_VERIFIED=0

:: Check icon file exists
echo Checking icon file...
if exist "!ICON_PATH!" (
    echo Found icon file: !ICON_PATH!
    
    :: Verify icon file size
    for %%F in ("!ICON_PATH!") do set ICON_SIZE=%%~zF
    echo Icon file size: !ICON_SIZE! bytes
    
    if !ICON_SIZE! LSS 1000 (
        echo Warning: Icon file is unusually small, might be corrupted
    ) else (
        echo Icon file size is normal
        set ICON_VERIFIED=1
    )

    :: Create icon backup for debugging
    echo Creating icon backup for debugging...
    copy "!ICON_PATH!" "!PROJECT_ROOT!\build\icon_backup.ico" >nul
    if not errorlevel 1 (
        echo Icon backup successful: !PROJECT_ROOT!\build\icon_backup.ico
    ) else (
        echo Warning: Icon backup failed
    )
) else (
    echo Warning: Icon file not found at !ICON_PATH!
)

:: Build using PyInstaller directly (simplified approach)
echo Building application with PyInstaller...

:: Prepare icon parameter if icon exists
set ICON_PARAM=
if !ICON_VERIFIED! EQU 1 (
    set ICON_PARAM=--icon="!ICON_PATH!"
    echo Using icon: !ICON_PATH!
) else (
    echo No valid icon found, building without icon
)

:: Run PyInstaller with all necessary parameters
pyinstaller --name SnakeGame ^
    --windowed ^
    !ICON_PARAM! ^
    --onedir ^
    --distpath "!PROJECT_ROOT!\build\windows_optimized" ^
    --workpath "!PROJECT_ROOT!\build\temp_optimized" ^
    --clean ^
    --add-data "assets;assets" ^
    --add-data "src\qml;src\qml" ^
    --add-data "config.toml;." ^
    --noconfirm ^
    "!MAIN_FILE!"

if errorlevel 1 (
    echo Build failed!
    echo Please check the error messages above
    pause
    exit /b 1
)

:: Verify executable was created successfully
set EXE_PATH=!PROJECT_ROOT!\build\windows_optimized\SnakeGame\SnakeGame.exe
if not exist "!EXE_PATH!" (
    echo Error: Executable was not created successfully
    echo Expected location: !EXE_PATH!
    pause
    exit /b 1
)

:: Alternative approach: Manually copy icon to output directory
if !ICON_VERIFIED! EQU 1 (
    echo Manually copying icon to output directories for better application support...
    
    :: Copy to root directory
    copy "!ICON_PATH!" "!PROJECT_ROOT!\build\windows_optimized\SnakeGame\icon.ico" >nul
    if not errorlevel 1 (
        echo Icon successfully copied to output root directory
    ) else (
        echo Warning: Failed to copy icon to output root directory
    )
    
    :: Copy to assets/images directory, ensure directory exists
    if not exist "!PROJECT_ROOT!\build\windows_optimized\SnakeGame\assets\images\" (
        mkdir "!PROJECT_ROOT!\build\windows_optimized\SnakeGame\assets\images\"
    )
    copy "!ICON_PATH!" "!PROJECT_ROOT!\build\windows_optimized\SnakeGame\assets\images\icon.ico" >nul
    if not errorlevel 1 (
        echo Icon successfully copied to assets/images directory
    ) else (
        echo Warning: Failed to copy icon to assets/images directory
    )
)

:: Safe file cleanup (don't touch Qt module structure)
echo Performing safe file cleanup...
for /r "!PROJECT_ROOT!\build\windows_optimized\SnakeGame" %%f in (*.pdb) do del /q "%%f" 2>nul
for /r "!PROJECT_ROOT!\build\windows_optimized\SnakeGame" %%f in (*.pyc) do del /q "%%f" 2>nul
for /r "!PROJECT_ROOT!\build\windows_optimized\SnakeGame" %%f in (*.pyo) do del /q "%%f" 2>nul
for /d /r "!PROJECT_ROOT!\build\windows_optimized\SnakeGame" %%d in (__pycache__) do rd /s /q "%%d" 2>nul

:: Calculate application size (simplified approach)
echo Calculating application size...
dir "!PROJECT_ROOT!\build\windows_optimized\SnakeGame" /s /-c | find "File(s)"

echo ========================================
echo Build completed successfully!
echo Application location: !PROJECT_ROOT!\build\windows_optimized\SnakeGame\
echo Executable: !PROJECT_ROOT!\build\windows_optimized\SnakeGame\SnakeGame.exe
echo You can run the application by double-clicking SnakeGame.exe
echo ========================================

:: Keep console open for review
pause 