#!/bin/bash

echo "========================================"
echo "Snake Game - macOS Build Script"
echo "========================================"

# Check if in the project root directory
if [ ! -f "../requirements.txt" ]; then
    echo "Error: Please run this script from the project root directory"
    echo "The current directory should contain requirements.txt file"
    exit 1
fi

# Check main program file
if [ ! -f "../snake_game_full.py" ]; then
    echo "Error: snake_game_full.py not found"
    echo "Please make sure the main program file exists"
    exit 1
fi

# Check Python environment
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 not found, please install Python 3.8+"
    exit 1
fi

# Move to project root directory
cd ..

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
mkdir -p build/macos
mkdir -p build/temp

# Use PyInstaller to package
echo "Building macOS application..."
pyinstaller --onefile \
    --windowed \
    --name "SnakeGame" \
    --distpath "build/macos" \
    --workpath "build/temp" \
    --specpath "build" \
    snake_game_full.py

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo "Creating .app bundle..."
mkdir -p "build/macos/SnakeGame.app/Contents/MacOS"
mkdir -p "build/macos/SnakeGame.app/Contents/Resources"
mkdir -p "build/macos/SnakeGame.app/Contents/Resources/src/qml"
mkdir -p "build/macos/SnakeGame.app/Contents/Resources/assets"

# Create Info.plist
cat > "build/macos/SnakeGame.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>SnakeGame</string>
    <key>CFBundleIdentifier</key>
    <string>com.snakegame.app</string>
    <key>CFBundleName</key>
    <string>Snake Game</string>
    <key>CFBundleDisplayName</key>
    <string>Snake Game</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>icon</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.14</string>
</dict>
</plist>
EOF

# Move executable to app bundle
mv "build/macos/SnakeGame" "build/macos/SnakeGame.app/Contents/MacOS/"

# Copy icon (if exists)
if [ -f "assets/images/icon.icns" ]; then
    cp "assets/images/icon.icns" "build/macos/SnakeGame.app/Contents/Resources/icon.icns"
fi

# Copy resource files
echo "Copying resource files..."
cp -r "src/qml" "build/macos/SnakeGame.app/Contents/Resources/src/"
cp -r "assets" "build/macos/SnakeGame.app/Contents/Resources/"
if [ -f "config.toml" ]; then
    cp "config.toml" "build/macos/SnakeGame.app/Contents/Resources/"
fi

echo "Build completed!"
echo "Application location: build/macos/SnakeGame.app"
echo "=========================================" 