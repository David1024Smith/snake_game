#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
from pathlib import Path
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType
from PySide6.QtCore import QUrl, QDir
from config_manager import ConfigManager
from game_engine import GameEngine, register_qml_types

def main():
    # 创建应用程序
    app = QGuiApplication(sys.argv)
    app.setApplicationName("Snake Game 2.0")
    app.setApplicationVersion("2.0.0")
    app.setOrganizationName("Snake Game Studio")
    
    # 设置应用图标
    icon_path = Path(__file__).parent.parent.parent / "assets" / "images" / "icon.png"
    if icon_path.exists():
        app.setWindowIcon(QIcon(str(icon_path)))
    
    # 初始化配置管理器
    config_manager = ConfigManager()
    
    # 初始化游戏引擎
    game_engine = GameEngine(config_manager)
    
    # 注册QML类型
    register_qml_types()
    
    # 创建QML引擎
    engine = QQmlApplicationEngine()
    
    # 注册Python对象到QML
    engine.rootContext().setContextProperty("configManager", config_manager)
    engine.rootContext().setContextProperty("gameEngine", game_engine)
    
    # 添加QML导入路径
    qml_dir = Path(__file__).parent.parent / "qml"
    engine.addImportPath(str(qml_dir))
    
    # 添加模块路径
    engine.addImportPath(str(Path(__file__).parent))
    
    # 设置QML文件搜索路径
    engine.addImportPath(str(qml_dir / "styles"))
    engine.addImportPath(str(qml_dir / "components"))
    
    # 注册 SnakeGame 模块
    qmlRegisterType(GameEngine, "SnakeGame", 1, 0, "GameEngine")
    qmlRegisterType(ConfigManager, "SnakeGame", 1, 0, "ConfigManager")
    
    # 加载主QML文件
    main_qml = qml_dir / "main.qml"
    if not main_qml.exists():
        print(f"错误: 找不到主QML文件: {main_qml}")
        return 1
    
    engine.load(QUrl.fromLocalFile(str(main_qml)))
    
    # 检查是否成功加载
    if not engine.rootObjects():
        print("错误: 无法加载QML文件")
        return 1
    
    # 运行应用程序
    return app.exec()

if __name__ == "__main__":
    sys.exit(main()) 