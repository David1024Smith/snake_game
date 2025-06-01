#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
贪吃蛇游戏 - 统一构建脚本
支持构建所有平台的应用程序
"""

import os
import sys
import subprocess
import platform
from pathlib import Path

def get_platform():
    """获取当前平台"""
    system = platform.system().lower()
    if system == "windows":
        return "windows"
    elif system == "darwin":
        return "macos"
    elif system == "linux":
        return "linux"
    else:
        return "unknown"

def run_build_script(script_path):
    """运行构建脚本"""
    if not Path(script_path).exists():
        print(f"错误: 构建脚本不存在: {script_path}")
        return False
    
    try:
        print(f"运行脚本: {script_path}")
        if script_path.endswith('.py'):
            subprocess.run([sys.executable, script_path], check=True)
        elif script_path.endswith('.sh'):
            subprocess.run(['bash', script_path], check=True)
        elif script_path.endswith('.bat'):
            subprocess.run([script_path], check=True, shell=True)
        else:
            print(f"错误: 不支持的脚本类型: {script_path}")
            return False
        return True
    except subprocess.CalledProcessError as e:
        print(f"构建失败: {e}")
        return False

def build_windows():
    """构建Windows版本"""
    print("构建Windows版本...")
    
    # 首先尝试使用package_snake.bat（cx_Freeze），如果存在
    if Path("package_snake.bat").exists():
        print("使用package_snake.bat构建...")
        return run_build_script("package_snake.bat")
    
    # 否则使用scripts目录下的build_windows.bat
    return run_build_script("scripts/build_windows.bat")

def build_macos():
    """构建macOS版本"""
    print("构建macOS版本...")
    return run_build_script("scripts/build_macos.sh")

def build_linux():
    """构建Linux版本"""
    print("构建Linux版本...")
    return run_build_script("scripts/build_linux.sh")

def build_android():
    """构建Android版本"""
    print("构建Android版本...")
    return run_build_script("scripts/build_android.py")

def build_ios():
    """构建iOS版本"""
    print("构建iOS版本...")
    current_platform = get_platform()
    if current_platform != "macos":
        print("错误: iOS构建只能在macOS上进行")
        return False
    return run_build_script("scripts/build_ios.py")

def show_menu():
    """显示构建菜单"""
    current_platform = get_platform()
    
    print("========================================")
    print("贪吃蛇游戏 - 统一构建脚本")
    print("========================================")
    print(f"当前平台: {current_platform}")
    print()
    print("请选择要构建的平台:")
    print("1. Windows (.exe)")
    print("2. macOS (.app)")
    print("3. Linux (executable)")
    print("4. Android (.apk)")
    print("5. iOS (.ipa)")
    print("6. 构建当前平台")
    print("7. 构建所有桌面平台")
    print("8. 构建所有移动平台")
    print("9. 使用cx_Freeze构建当前平台 (更简单)")
    print("0. 退出")
    print("========================================")

def build_with_cx_freeze():
    """使用cx_Freeze构建当前平台"""
    print("使用cx_Freeze构建当前平台...")
    
    current_platform = get_platform()
    if current_platform == "windows":
        if Path("package_snake.bat").exists():
            return run_build_script("package_snake.bat")
        else:
            print("错误: package_snake.bat不存在")
            return False
    else:
        # 为其他平台创建简单的setup.py并运行
        setup_py = """
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
    executables=[Executable("snake_game_full.py", base=base, target_name="SnakeGame")]
)
"""
        with open("setup.py", "w") as f:
            f.write(setup_py)
        
        try:
            subprocess.run([sys.executable, "-m", "pip", "install", "cx_Freeze"], check=True)
            subprocess.run([sys.executable, "setup.py", "build"], check=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"构建失败: {e}")
            return False

def main():
    """主函数"""
    # 检查是否在项目根目录
    if not Path("requirements.txt").exists():
        print("错误: 请在项目根目录运行此脚本")
        return 1
    
    # 检查主程序文件
    if not Path("snake_game_full.py").exists():
        print("错误: snake_game_full.py不存在")
        return 1
    
    while True:
        show_menu()
        choice = input("请输入选择 (0-9): ").strip()
        
        if choice == "0":
            print("退出构建脚本")
            break
        elif choice == "1":
            build_windows()
        elif choice == "2":
            build_macos()
        elif choice == "3":
            build_linux()
        elif choice == "4":
            build_android()
        elif choice == "5":
            build_ios()
        elif choice == "6":
            # 构建当前平台
            current_platform = get_platform()
            if current_platform == "windows":
                build_windows()
            elif current_platform == "macos":
                build_macos()
            elif current_platform == "linux":
                build_linux()
            else:
                print(f"不支持的平台: {current_platform}")
        elif choice == "7":
            # 构建所有桌面平台
            print("构建所有桌面平台...")
            current_platform = get_platform()
            if current_platform == "windows":
                build_windows()
            elif current_platform == "macos":
                build_macos()
                build_windows()  # 可以在macOS上交叉编译Windows
            elif current_platform == "linux":
                build_linux()
            print("桌面平台构建完成")
        elif choice == "8":
            # 构建所有移动平台
            print("构建所有移动平台...")
            build_android()
            current_platform = get_platform()
            if current_platform == "macos":
                build_ios()
            else:
                print("iOS构建需要在macOS上进行")
            print("移动平台构建完成")
        elif choice == "9":
            # 使用cx_Freeze构建当前平台
            build_with_cx_freeze()
        else:
            print("无效选择，请重新输入")
        
        input("\n按回车键继续...")
    
    return 0

if __name__ == "__main__":
    sys.exit(main()) 