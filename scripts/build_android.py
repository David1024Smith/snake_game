#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
贪吃蛇游戏 - Android 打包脚本
使用 Briefcase 将 PySide6 应用打包为 Android APK
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

def check_requirements():
    """检查打包环境要求"""
    print("检查打包环境...")
    
    # 检查Python版本
    if sys.version_info < (3, 8):
        print("错误: 需要Python 3.8或更高版本")
        return False
    
    # 检查是否在项目根目录
    if not Path("requirements.txt").exists():
        print("错误: 请在项目根目录运行此脚本")
        return False
    
    # 检查主程序文件
    if not Path("snake_game_full.py").exists():
        print("错误: snake_game_full.py不存在")
        print("请确保主程序文件存在")
        return False
    
    # 检查Android SDK
    android_home = os.environ.get('ANDROID_HOME')
    if not android_home:
        print("警告: 未设置ANDROID_HOME环境变量")
        print("请安装Android SDK并设置环境变量")
    
    return True

def install_dependencies():
    """安装打包依赖"""
    print("安装打包依赖...")
    
    try:
        # 升级pip
        subprocess.run([sys.executable, "-m", "pip", "install", "--upgrade", "pip"], check=True)
        
        # 安装项目依赖
        subprocess.run([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"], check=True)
        
        # 安装Briefcase
        subprocess.run([sys.executable, "-m", "pip", "install", "briefcase"], check=True)
        
        print("依赖安装完成")
        return True
    except subprocess.CalledProcessError as e:
        print(f"依赖安装失败: {e}")
        return False

def create_pyproject_toml():
    """创建pyproject.toml配置文件"""
    print("创建Briefcase配置文件...")
    
    pyproject_content = '''[build-system]
requires = ["briefcase"]

[tool.briefcase]
project_name = "Snake Game"
bundle = "com.snakegame"
version = "1.0.0"
url = "https://github.com/snakegame/snake-game"
license = "MIT"
author = "Snake Game Studio"
author_email = "contact@snakegame.com"

[tool.briefcase.app.snakegame]
formal_name = "贪吃蛇游戏"
description = "现代化跨平台贪吃蛇游戏"
icon = "assets/images/icon"
sources = ["snake_game_full.py", "src"]
requires = [
    "PySide6>=6.5.0",
    "toml>=0.10.2",
]

[tool.briefcase.app.snakegame.android]
requires = [
    "PySide6>=6.5.0",
    "toml>=0.10.2",
]
build_gradle_dependencies = [
    "implementation 'androidx.appcompat:appcompat:1.4.2'",
    "implementation 'com.google.android.material:material:1.6.1'",
]
'''
    
    with open("pyproject.toml", "w", encoding="utf-8") as f:
        f.write(pyproject_content)
    
    print("配置文件创建完成")

def prepare_android_files():
    """准备Android构建所需文件"""
    print("准备Android构建文件...")
    
    # 创建临时构建目录
    build_dir = Path("build/android")
    build_dir.mkdir(parents=True, exist_ok=True)
    
    # 复制主程序文件
    shutil.copy2("snake_game_full.py", build_dir)
    
    # 复制资源文件
    qml_dir = build_dir / "src" / "qml"
    qml_dir.mkdir(parents=True, exist_ok=True)
    if Path("src/qml").exists():
        shutil.copytree("src/qml", qml_dir, dirs_exist_ok=True)
    
    # 复制assets
    assets_dir = build_dir / "assets"
    assets_dir.mkdir(parents=True, exist_ok=True)
    if Path("assets").exists():
        shutil.copytree("assets", assets_dir, dirs_exist_ok=True)
    
    # 复制配置文件
    if Path("config.toml").exists():
        shutil.copy2("config.toml", build_dir)
    
    print("文件准备完成")
    return True

def build_android():
    """构建Android APK"""
    print("开始构建Android APK...")
    
    try:
        # 创建Android项目
        print("创建Android项目...")
        subprocess.run([sys.executable, "-m", "briefcase", "create", "android"], check=True)
        
        # 构建APK
        print("构建APK...")
        subprocess.run([sys.executable, "-m", "briefcase", "build", "android"], check=True)
        
        # 打包APK
        print("打包APK...")
        subprocess.run([sys.executable, "-m", "briefcase", "package", "android"], check=True)
        
        print("Android APK构建完成!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"构建失败: {e}")
        return False

def copy_output_files():
    """复制输出文件"""
    print("复制输出文件...")
    
    # 创建输出目录
    dist_dir = Path("build/dist")
    dist_dir.mkdir(parents=True, exist_ok=True)
    
    # 查找并复制生成的APK
    apk_files = list(Path(".").glob("**/snakegame-*.apk"))
    if apk_files:
        for apk in apk_files:
            target = dist_dir / apk.name
            shutil.copy2(apk, target)
            print(f"已复制APK: {target}")
    else:
        print("警告: 未找到生成的APK文件")
    
    print("文件复制完成")

def main():
    """主函数"""
    print("========================================")
    print("贪吃蛇游戏 - Android 打包脚本")
    print("========================================")
    
    # 检查环境
    if not check_requirements():
        return 1
    
    # 安装依赖
    if not install_dependencies():
        return 1
    
    # 创建配置文件
    create_pyproject_toml()
    
    # 准备文件
    if not prepare_android_files():
        return 1
    
    # 构建APK
    if not build_android():
        return 1
    
    # 复制输出文件
    copy_output_files()
    
    print("========================================")
    print("Android APK构建成功!")
    print("APK位置: build/dist/")
    print("========================================")
    
    return 0

if __name__ == "__main__":
    sys.exit(main()) 