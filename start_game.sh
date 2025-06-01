#!/bin/bash
echo "========================================"
echo "Snake Game 2.0 - Starting Game"
echo "========================================"

# Check if snake_game_full.py exists
if [ ! -f "snake_game_full.py" ]; then
    echo "Error: snake_game_full.py not found!"
    echo "Please make sure you are in the project root directory."
    read -p "Press any key to continue..."
    exit 1
fi

# Check Python environment
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 not found!"
    echo "Please install Python 3.8+ and PySide6"
    echo "Run: pip3 install PySide6"
    read -p "Press any key to continue..."
    exit 1
fi

echo "Starting Snake Game 2.0..."
python3 snake_game_full.py

if [ $? -ne 0 ]; then
    echo "Error: Failed to start the game!"
    echo "Make sure all dependencies are installed."
    echo "Run: pip3 install -r requirements.txt"
    read -p "Press any key to continue..."
    exit 1
fi

echo "Game closed." 