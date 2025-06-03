#!/bin/bash

echo "========================================"
echo "Snake Game - macOS Build Script (安全优化版)"
echo "========================================"

# Detect current directory and set project root
if [ -f "requirements.txt" ] && [ -d "src" ]; then
    # Running from project root
    PROJECT_ROOT="."
    echo "Running from project root directory"
elif [ -f "../requirements.txt" ] && [ -d "../src" ]; then
    # Running from scripts directory
    PROJECT_ROOT=".."
    echo "Running from scripts directory"
else
    echo "Error: Please run this script from either:"
    echo "  1. Project root directory (containing requirements.txt)"
    echo "  2. Scripts directory (scripts/)"
    exit 1
fi

# Check main program file
if [ ! -f "$PROJECT_ROOT/src/python/main.py" ]; then
    echo "Error: src/python/main.py not found"
    echo "Please make sure the main program file exists in the new architecture"
    exit 1
fi

# Check Python environment
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 not found, please install Python 3.8+"
    exit 1
fi

# Move to project root directory
cd "$PROJECT_ROOT"

# Create virtual environment
echo "Creating virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
python -m pip install --upgrade pip

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Create build directories
mkdir -p build/macos_safe_optimized
mkdir -p build/temp_safe_optimized

# Check if icon exists
ICON_PATH=""
if [ -f "assets/images/icon.icns" ]; then
    ICON_PATH="--icon=$(pwd)/assets/images/icon.icns"
    echo "Using custom icon: $(pwd)/assets/images/icon.icns"
else
    echo "Warning: No icon file found at assets/images/icon.icns"
fi

# Use PyInstaller to package (安全优化版 - 只排除明确不需要的大型库)
echo "Building macOS application (安全优化版)..."
pyinstaller --onedir \
    --windowed \
    --name "SnakeGame" \
    --distpath "build/macos_safe_optimized" \
    --workpath "build/temp_safe_optimized" \
    --specpath "build" \
    $ICON_PATH \
    --add-data "$(pwd)/src/qml:src/qml" \
    --add-data "$(pwd)/assets:assets" \
    --add-data "$(pwd)/config.toml:." \
    --exclude-module tkinter \
    --exclude-module matplotlib \
    --exclude-module numpy \
    --exclude-module scipy \
    --exclude-module pandas \
    --exclude-module PIL \
    --exclude-module cv2 \
    --exclude-module tensorflow \
    --exclude-module torch \
    --exclude-module jupyter \
    --exclude-module IPython \
    --exclude-module notebook \
    --exclude-module sphinx \
    --exclude-module pytest \
    --hidden-import PySide6.QtCore \
    --hidden-import PySide6.QtGui \
    --hidden-import PySide6.QtQml \
    --hidden-import PySide6.QtQuick \
    --hidden-import PySide6.QtOpenGL \
    --hidden-import PySide6.QtNetwork \
    --hidden-import PySide6.QtDBus \
    --strip \
    --optimize 2 \
    src/python/main.py

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# Check if .app bundle was created successfully
if [ ! -d "build/macos_safe_optimized/SnakeGame.app" ]; then
    echo "Error: .app bundle was not created successfully"
    exit 1
fi

# Verify essential files exist
if [ ! -f "build/macos_safe_optimized/SnakeGame.app/Contents/MacOS/SnakeGame" ]; then
    echo "Error: Executable not found in .app bundle"
    exit 1
fi

# 安全的文件清理（不触及Qt模块结构）
echo "进行安全的文件清理..."
find "build/macos_safe_optimized/SnakeGame.app" -name "*.dSYM" -exec rm -rf {} + 2>/dev/null || true
find "build/macos_safe_optimized/SnakeGame.app" -name "*.pdb" -delete 2>/dev/null || true
find "build/macos_safe_optimized/SnakeGame.app" -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find "build/macos_safe_optimized/SnakeGame.app" -name "*.pyc" -delete 2>/dev/null || true
find "build/macos_safe_optimized/SnakeGame.app" -name "*.pyo" -delete 2>/dev/null || true

# Check final size
APP_SIZE=$(du -sh "build/macos_safe_optimized/SnakeGame.app" | cut -f1)
echo "Build completed successfully!"
echo "Application location: build/macos_safe_optimized/SnakeGame.app"
echo "Application size: $APP_SIZE"
echo "You can run the app by double-clicking it in Finder or using: open build/macos_safe_optimized/SnakeGame.app"
echo "=========================================" 