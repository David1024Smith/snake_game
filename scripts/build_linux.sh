#!/bin/bash
echo "========================================"
echo "Snake Game - Linux Build Script"
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
mkdir -p build/linux
mkdir -p build/temp

# Use PyInstaller to package
echo "Building Linux executable..."
pyinstaller --onefile \
    --windowed \
    --name "SnakeGame" \
    --distpath "build/linux" \
    --workpath "build/temp" \
    --specpath "build" \
    snake_game_full.py

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# Copy resource files
echo "Copying resource files..."
mkdir -p "build/linux/src"
mkdir -p "build/linux/src/qml"
mkdir -p "build/linux/assets"

cp -r "src/qml" "build/linux/src/"
cp -r "assets" "build/linux/"
if [ -f "config.toml" ]; then
    cp "config.toml" "build/linux/"
fi

# Set executable permissions
chmod +x "build/linux/SnakeGame"

echo "Build completed!"
echo "Executable location: build/linux/SnakeGame"
echo "=========================================" 