#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
贪吃蛇游戏主程序
"""

import sys
import os
from pathlib import Path
from PySide6.QtCore import QUrl, QObject, Signal, Slot, Property
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine

# 添加当前目录到Python路径
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

from game_engine import GameEngine, register_qml_types
from config_manager import ConfigManager

def get_qml_path():
    """获取QML文件路径，支持开发环境和打包环境"""
    
    # 检查是否在PyInstaller打包环境中
    if getattr(sys, 'frozen', False) and hasattr(sys, '_MEIPASS'):
        # PyInstaller打包环境
        base_path = Path(sys._MEIPASS)
        qml_path = base_path / "src" / "qml" / "main.qml"
        print(f"Running in packaged environment, QML path: {qml_path}")
        return qml_path
    else:
        # 开发环境
        current_dir = Path(__file__).parent
        qml_path = current_dir.parent / "qml" / "main.qml"
        print(f"Running in development environment, QML path: {qml_path}")
        return qml_path

def get_icon_path():
    """获取应用图标路径，支持开发环境和打包环境"""
    try:
        # 检查是否在PyInstaller打包环境中
        if getattr(sys, 'frozen', False) and hasattr(sys, '_MEIPASS'):
            # PyInstaller打包环境
            base_path = Path(sys._MEIPASS)
            # 尝试多个可能的图标位置
            icon_paths = [
                base_path / "assets" / "images" / "icon.ico",
                base_path / "icon.ico",  # 备选位置1（从构建脚本手动复制的）
                base_path / "assets" / "images" / "icon.png"
            ]
        else:
            # 开发环境
            current_dir = Path(__file__).parent
            project_root = current_dir.parent.parent  # 项目根目录
            # 尝试多个可能的图标位置
            icon_paths = [
                project_root / "assets" / "images" / "icon.ico",
                project_root / "assets" / "images" / "icon.png"
            ]
        
        # 尝试所有可能的图标路径
        for icon_path in icon_paths:
            if icon_path.exists():
                print(f"Found application icon: {icon_path}")
                return str(icon_path)
        
        print("Warning: Application icon not found!")
        return None
    except Exception as e:
        print(f"Error in get_icon_path: {e}")
        return None

class GameInitializer(QObject):
    """游戏初始化类，确保游戏引擎正确地传递给QML"""
    
    def __init__(self, engine, parent=None):
        super().__init__(parent)
        self.engine = engine
        self.game_engine = None
        self.config_manager = None
    
    def initialize(self):
        """初始化游戏组件并连接到QML"""
        # 创建配置管理器
        self.config_manager = ConfigManager()
        
        # 创建游戏引擎
        self.game_engine = GameEngine(self.config_manager)
        
        # 注册Python对象到QML
        self.engine.rootContext().setContextProperty("gameEngine", self.game_engine)
        self.engine.rootContext().setContextProperty("configManager", self.config_manager)
        
        print("Game engine and config manager initialized and registered with QML")
        return True

def main():
    print("Starting Snake Game...")
    app = QGuiApplication(sys.argv)
    
    try:
        # 设置应用图标 - 安全方式，确保错误不会传播
        icon_path = get_icon_path()
        if icon_path:
            try:
                print(f"Setting application icon: {icon_path}")
                app.setWindowIcon(QIcon(icon_path))
            except Exception as e:
                print(f"Error setting window icon: {e}")
    except Exception as e:
        print(f"Error in icon initialization: {e}")
    
    # 注册QML类型
    register_qml_types()
    
    # 创建QML引擎
    engine = QQmlApplicationEngine()
    
    # 创建游戏组件
    config_manager = ConfigManager()
    game_engine = GameEngine(config_manager)
    
    # 获取QML文件路径
    main_qml = get_qml_path()
    
    # 检查QML文件是否存在
    if not main_qml.exists():
        print(f"Error: QML file not found at {main_qml}")
        print("Searching for QML files...")
        
        # 尝试查找QML文件
        if getattr(sys, 'frozen', False):
            # 在打包环境中搜索
            base_path = Path(sys._MEIPASS)
            for qml_file in base_path.rglob("main.qml"):
                print(f"Found QML file: {qml_file}")
                main_qml = qml_file
                break
        
        if not main_qml.exists():
            print("Failed to locate QML file!")
            return 1
    
    # 注册Python对象到QML（先设置context property）
    print("Setting context properties...")
    engine.rootContext().setContextProperty("gameEngine", game_engine)
    engine.rootContext().setContextProperty("configManager", config_manager)
    
    print(f"Loading QML from: {main_qml}")
    
    # 加载QML文件
    engine.load(QUrl.fromLocalFile(str(main_qml)))
    
    if not engine.rootObjects():
        print("Failed to load QML!")
        return 1
    
    print("Game started successfully!")
    return app.exec()

if __name__ == "__main__":
    sys.exit(main()) 