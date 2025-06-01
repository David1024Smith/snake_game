#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
贪吃蛇游戏 - iOS 打包脚本
使用 Briefcase 将 PySide6 应用打包为 iOS 应用
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
    
    # 检查是否在macOS上
    if sys.platform != "darwin":
        print("错误: iOS打包只能在macOS上进行")
        return False
    
    # 检查Xcode
    try:
        subprocess.run(["xcode-select", "--version"], check=True, capture_output=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("错误: 未找到Xcode，请先安装Xcode")
        return False
    
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

[tool.briefcase.app.snakegame.iOS]
requires = [
    "PySide6>=6.5.0",
    "toml>=0.10.2",
]
supported_versions = ["13.0"]
'''
    
    with open("pyproject.toml", "w", encoding="utf-8") as f:
        f.write(pyproject_content)
    
    print("配置文件创建完成")

def prepare_ios_files():
    """准备iOS构建所需文件"""
    print("准备iOS构建文件...")
    
    # 创建临时构建目录
    build_dir = Path("build/ios")
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

def build_ios():
    """构建iOS应用"""
    print("开始构建iOS应用...")
    
    try:
        # 创建iOS项目
        print("创建iOS项目...")
        subprocess.run([sys.executable, "-m", "briefcase", "create", "iOS"], check=True)
        
        # 构建iOS应用
        print("构建iOS应用...")
        subprocess.run([sys.executable, "-m", "briefcase", "build", "iOS"], check=True)
        
        # 打包iOS应用
        print("打包iOS应用...")
        subprocess.run([sys.executable, "-m", "briefcase", "package", "iOS"], check=True)
        
        print("iOS应用构建完成!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"构建失败: {e}")
        print("提示: iOS应用需要Apple开发者账号进行签名")
        return False

def copy_output_files():
    """复制输出文件"""
    print("复制输出文件...")
    
    # 创建输出目录
    dist_dir = Path("build/dist")
    dist_dir.mkdir(parents=True, exist_ok=True)
    
    # 查找并复制生成的IPA
    ipa_files = list(Path(".").glob("**/snakegame-*.ipa"))
    if ipa_files:
        for ipa in ipa_files:
            target = dist_dir / ipa.name
            shutil.copy2(ipa, target)
            print(f"已复制IPA: {target}")
    else:
        print("警告: 未找到生成的IPA文件")
    
    print("文件复制完成")

def main():
    """主函数"""
    print("========================================")
    print("贪吃蛇游戏 - iOS 打包脚本")
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
    if not prepare_ios_files():
        return 1
    
    # 构建iOS应用
    if not build_ios():
        return 1
    
    # 复制输出文件
    copy_output_files()
    
    print("========================================")
    print("iOS应用构建成功!")
    print("应用位置: build/dist/")
    print("注意: 需要使用Xcode进行最终签名和发布")
    print("========================================")
    
    return 0

if __name__ == "__main__":
    sys.exit(main()) 