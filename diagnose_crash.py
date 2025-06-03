#!/usr/bin/env python3
"""
Snake Game - 崩溃诊断工具
用于分析应用闪退的原因并提供修复建议
"""

import sys
import os
import subprocess
import json
from pathlib import Path

def check_app_structure(app_path):
    """检查应用结构完整性"""
    print("🔍 检查应用结构...")
    
    required_files = [
        "Contents/MacOS/SnakeGame",
        "Contents/Info.plist",
        "Contents/Resources",
        "Contents/Frameworks"
    ]
    
    missing_files = []
    for file_path in required_files:
        full_path = Path(app_path) / file_path
        if not full_path.exists():
            missing_files.append(file_path)
    
    if missing_files:
        print("❌ 缺少必要文件:")
        for file in missing_files:
            print(f"   - {file}")
        return False
    else:
        print("✅ 应用结构完整")
        return True

def check_qt_modules(app_path):
    """检查Qt模块完整性"""
    print("\n🔍 检查Qt模块...")
    
    qt_path = Path(app_path) / "Contents/Frameworks/PySide6/Qt"
    if not qt_path.exists():
        print("❌ PySide6/Qt 目录不存在")
        return False
    
    required_qt_modules = [
        "lib/QtCore.framework",
        "lib/QtGui.framework",
        "lib/QtQml.framework",
        "lib/QtQuick.framework",
        "qml/QtQuick",
        "qml/QtQml",
        "plugins/platforms"
    ]
    
    missing_modules = []
    for module in required_qt_modules:
        module_path = qt_path / module
        if not module_path.exists():
            missing_modules.append(module)
    
    if missing_modules:
        print("❌ 缺少Qt模块:")
        for module in missing_modules:
            print(f"   - {module}")
        return False
    else:
        print("✅ Qt模块完整")
        return True

def check_resources(app_path):
    """检查资源文件"""
    print("\n🔍 检查资源文件...")
    
    resource_path = Path(app_path) / "Contents/Resources"
    required_resources = [
        "src/qml",
        "assets",
        "config.toml"
    ]
    
    missing_resources = []
    for resource in required_resources:
        resource_full_path = resource_path / resource
        if not resource_full_path.exists():
            missing_resources.append(resource)
    
    if missing_resources:
        print("❌ 缺少资源文件:")
        for resource in missing_resources:
            print(f"   - {resource}")
        return False
    else:
        print("✅ 资源文件完整")
        return True

def test_executable(app_path):
    """测试可执行文件"""
    print("\n🔍 测试可执行文件...")
    
    executable_path = Path(app_path) / "Contents/MacOS/SnakeGame"
    
    # 检查文件权限
    if not os.access(executable_path, os.X_OK):
        print("❌ 可执行文件没有执行权限")
        return False
    
    # 检查文件类型
    try:
        result = subprocess.run(['file', str(executable_path)], 
                              capture_output=True, text=True)
        if 'Mach-O' not in result.stdout:
            print(f"❌ 可执行文件格式异常: {result.stdout}")
            return False
    except Exception as e:
        print(f"❌ 无法检查可执行文件: {e}")
        return False
    
    print("✅ 可执行文件正常")
    return True

def get_crash_logs():
    """获取崩溃日志"""
    print("\n🔍 查找崩溃日志...")
    
    crash_log_paths = [
        "~/Library/Logs/DiagnosticReports",
        "/Library/Logs/DiagnosticReports"
    ]
    
    crash_logs = []
    for log_path in crash_log_paths:
        expanded_path = Path(log_path).expanduser()
        if expanded_path.exists():
            for log_file in expanded_path.glob("SnakeGame*.crash"):
                crash_logs.append(log_file)
    
    if crash_logs:
        print(f"📋 找到 {len(crash_logs)} 个崩溃日志:")
        for log in crash_logs[-3:]:  # 显示最近3个
            print(f"   - {log}")
        return crash_logs
    else:
        print("ℹ️  未找到崩溃日志")
        return []

def analyze_dependencies(app_path):
    """分析依赖关系"""
    print("\n🔍 分析依赖关系...")
    
    executable_path = Path(app_path) / "Contents/MacOS/SnakeGame"
    
    try:
        result = subprocess.run(['otool', '-L', str(executable_path)], 
                              capture_output=True, text=True)
        
        dependencies = result.stdout.split('\n')[1:]  # 跳过第一行
        dependencies = [dep.strip().split(' ')[0] for dep in dependencies if dep.strip()]
        
        print("📦 主要依赖:")
        for dep in dependencies[:10]:  # 显示前10个
            if dep:
                print(f"   - {dep}")
        
        return dependencies
    except Exception as e:
        print(f"❌ 无法分析依赖关系: {e}")
        return []

def provide_recommendations(issues):
    """提供修复建议"""
    print("\n💡 修复建议:")
    
    if not issues:
        print("✅ 未发现明显问题，应用结构看起来正常")
        print("   建议:")
        print("   1. 尝试从终端运行应用以查看详细错误信息")
        print("   2. 检查系统控制台日志")
        print("   3. 确保系统满足最低要求")
        return
    
    if "structure" in issues:
        print("🔧 应用结构问题:")
        print("   - 重新运行打包脚本")
        print("   - 检查PyInstaller版本是否兼容")
    
    if "qt_modules" in issues:
        print("🔧 Qt模块问题:")
        print("   - 使用安全优化版打包脚本 (build_macos_safe_optimized.sh)")
        print("   - 避免过度排除Qt模块")
    
    if "resources" in issues:
        print("🔧 资源文件问题:")
        print("   - 检查 --add-data 参数是否正确")
        print("   - 确保资源文件路径存在")
    
    if "executable" in issues:
        print("🔧 可执行文件问题:")
        print("   - 重新打包应用")
        print("   - 检查Python环境和依赖")

def main():
    print("=" * 50)
    print("🐍 Snake Game - 崩溃诊断工具")
    print("=" * 50)
    
    # 查找应用
    app_paths = [
        "build/macos/SnakeGame.app",
        "build/macos_optimized/SnakeGame.app",
        "build/macos_safe_optimized/SnakeGame.app"
    ]
    
    found_apps = []
    for app_path in app_paths:
        if Path(app_path).exists():
            found_apps.append(app_path)
    
    if not found_apps:
        print("❌ 未找到任何已打包的应用")
        print("请先运行打包脚本创建应用")
        return
    
    print(f"📱 找到 {len(found_apps)} 个应用:")
    for i, app in enumerate(found_apps):
        print(f"   {i+1}. {app}")
    
    # 选择要诊断的应用
    if len(found_apps) == 1:
        selected_app = found_apps[0]
    else:
        try:
            choice = int(input("\n请选择要诊断的应用 (输入数字): ")) - 1
            selected_app = found_apps[choice]
        except (ValueError, IndexError):
            print("❌ 无效选择")
            return
    
    print(f"\n🔍 诊断应用: {selected_app}")
    print("-" * 50)
    
    issues = []
    
    # 执行各项检查
    if not check_app_structure(selected_app):
        issues.append("structure")
    
    if not check_qt_modules(selected_app):
        issues.append("qt_modules")
    
    if not check_resources(selected_app):
        issues.append("resources")
    
    if not test_executable(selected_app):
        issues.append("executable")
    
    # 获取崩溃日志
    crash_logs = get_crash_logs()
    
    # 分析依赖
    dependencies = analyze_dependencies(selected_app)
    
    # 提供建议
    provide_recommendations(issues)
    
    print("\n" + "=" * 50)
    print("诊断完成")
    print("=" * 50)

if __name__ == "__main__":
    main() 