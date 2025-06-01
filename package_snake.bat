@echo off
echo ========================================
echo Snake Game - Simple Packaging Script
echo ========================================

:: 激活虚拟环境
echo Activating virtual environment...
call venv\Scripts\activate.bat

:: 确保依赖已安装
echo Installing required packages...
python -m pip install PySide6 cx_Freeze

:: 创建简单的setup.py
echo Creating setup.py for cx_Freeze...
echo import sys > setup.py
echo from cx_Freeze import setup, Executable >> setup.py
echo. >> setup.py
echo build_exe_options = { >> setup.py
echo     "packages": ["sys", "random", "enum", "PySide6"], >> setup.py
echo     "excludes": [], >> setup.py
echo     "include_files": ["src/", "assets/", "config.toml"], >> setup.py
echo } >> setup.py
echo. >> setup.py
echo base = None >> setup.py
echo if sys.platform == "win32": >> setup.py
echo     base = "Win32GUI" >> setup.py
echo. >> setup.py
echo setup( >> setup.py
echo     name="SnakeGame", >> setup.py
echo     version="1.0", >> setup.py
echo     description="Modern Snake Game", >> setup.py
echo     options={"build_exe": build_exe_options}, >> setup.py
echo     executables=[Executable("snake_game_full.py", base=base, icon="assets/images/icon.ico", target_name="SnakeGame.exe")] >> setup.py
echo ) >> setup.py

:: 构建可执行文件
echo Building executable with cx_Freeze...
python setup.py build

:: 完成
echo ========================================
if exist "build\exe.win-amd64-3.13" (
    echo Build completed!
    echo Executable location: build\exe.win-amd64-3.13\SnakeGame.exe
    echo ========================================
) else (
    echo Build failed. Check the error messages above.
)

pause 