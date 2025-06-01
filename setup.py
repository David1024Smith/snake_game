import sys 
from cx_Freeze import setup, Executable 
 
build_exe_options = { 
    "packages": ["sys", "random", "enum", "PySide6"], 
    "excludes": [], 
    "include_files": ["src/", "assets/", "config.toml"], 
} 
 
base = None 
if sys.platform == "win32": 
    base = "Win32GUI" 
 
setup( 
    name="SnakeGame", 
    version="1.0", 
    description="Modern Snake Game", 
    options={"build_exe": build_exe_options}, 
    executables=[Executable("snake_game_full.py", base=base, icon="assets/images/icon.ico", target_name="SnakeGame.exe")] 
) 
