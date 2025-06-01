@echo off
echo ========================================
echo Snake Game 2.0 - Starting Game
echo ========================================

:: Check if snake_game_full.py exists
if not exist "snake_game_full.py" (
    echo Error: snake_game_full.py not found!
    echo Please make sure you are in the project root directory.
    pause
    exit /b 1
)

:: Check Python environment
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python environment not found!
    echo Please install Python 3.8+ and PySide6
    echo Run: pip install PySide6
    pause
    exit /b 1
)

echo Starting Snake Game 2.0...
python snake_game_full.py

if errorlevel 1 (
    echo Error: Failed to start the game!
    echo Make sure all dependencies are installed.
    echo Run: pip install -r requirements.txt
    pause
    exit /b 1
)

echo Game closed.
pause 