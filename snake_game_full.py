#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
完整的贪吃蛇游戏 - 包含主菜单和游戏模式选择
"""

import sys
import random
from enum import Enum
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType

class Direction(Enum):
    UP = (0, -1)
    DOWN = (0, 1)
    LEFT = (-1, 0)
    RIGHT = (1, 0)

class GameState(Enum):
    MENU = "menu"
    PLAYING = "playing"
    PAUSED = "paused"
    GAME_OVER = "game_over"

class GameMode(Enum):
    CLASSIC = "classic"
    MODERN = "modern"
    TIME_ATTACK = "time_attack"
    FREESTYLE = "freestyle"

class SnakeGame(QObject):
    """完整的贪吃蛇游戏引擎"""
    
    # 信号
    gameStateChanged = Signal(str)
    scoreChanged = Signal(int)
    snakePositionsChanged = Signal('QVariant')
    foodPositionChanged = Signal('QVariant')
    gameModeChanged = Signal(str)
    difficultyChanged = Signal(int)
    
    def __init__(self):
        super().__init__()
        
        # 游戏配置
        self._grid_width = 30
        self._grid_height = 20
        self._game_mode = GameMode.CLASSIC
        self._difficulty = 5
        self._game_speed = 200  # ms
        
        # 游戏状态
        self._game_state = GameState.MENU
        self._score = 0
        
        # 蛇的状态
        self._snake_positions = [(15, 10)]  # 中心位置
        self._snake_direction = Direction.RIGHT
        self._next_direction = Direction.RIGHT
        self._snake_growing = 0
        
        # 食物位置
        self._food_position = (20, 10)
        
        # 游戏计时器
        self.game_timer = QTimer()
        self.game_timer.timeout.connect(self.update_game)
        
        self._spawn_food()
        print("SnakeGame initialized!")
    
    # Properties
    @Property(str, notify=gameStateChanged)
    def gameState(self):
        return self._game_state.value
    
    @Property(int, notify=scoreChanged)
    def score(self):
        return self._score
    
    @Property('QVariant', notify=snakePositionsChanged)
    def snakePositions(self):
        return [{"x": pos[0], "y": pos[1]} for pos in self._snake_positions]
    
    @Property('QVariant', notify=foodPositionChanged)
    def foodPosition(self):
        return {"x": self._food_position[0], "y": self._food_position[1]}
    
    @Property(int)
    def gridWidth(self):
        return self._grid_width
    
    @Property(int)
    def gridHeight(self):
        return self._grid_height
    
    @Property(str, notify=gameModeChanged)
    def gameMode(self):
        return self._game_mode.value
    
    @Property(int, notify=difficultyChanged)
    def difficulty(self):
        return self._difficulty
    
    # Slots
    @Slot(str, int)
    def setGameMode(self, mode, difficulty):
        """设置游戏模式和难度"""
        print(f"Setting game mode: {mode}, difficulty: {difficulty}")
        
        mode_map = {
            "classic": GameMode.CLASSIC,
            "modern": GameMode.MODERN,
            "time_attack": GameMode.TIME_ATTACK,
            "freestyle": GameMode.FREESTYLE
        }
        
        if mode in mode_map:
            self._game_mode = mode_map[mode]
            self.gameModeChanged.emit(self._game_mode.value)
        
        self._difficulty = max(1, min(10, difficulty))
        self._game_speed = max(50, 300 - (self._difficulty * 25))
        self.difficultyChanged.emit(self._difficulty)
        
        # 根据模式调整网格大小
        if self._game_mode == GameMode.MODERN:
            self._grid_width = 40
            self._grid_height = 25
        elif self._game_mode == GameMode.TIME_ATTACK:
            self._grid_width = 25
            self._grid_height = 15
        else:
            self._grid_width = 30
            self._grid_height = 20
    
    @Slot()
    def startGame(self):
        """开始游戏"""
        print(f"Starting game with mode: {self._game_mode.value}, difficulty: {self._difficulty}")
        self._game_state = GameState.PLAYING
        self.game_timer.start(self._game_speed)
        self.gameStateChanged.emit(self._game_state.value)
    
    @Slot()
    def pauseGame(self):
        """暂停/恢复游戏"""
        if self._game_state == GameState.PLAYING:
            print("Pausing game...")
            self._game_state = GameState.PAUSED
            self.game_timer.stop()
        elif self._game_state == GameState.PAUSED:
            print("Resuming game...")
            self._game_state = GameState.PLAYING
            self.game_timer.start(self._game_speed)
        self.gameStateChanged.emit(self._game_state.value)
    
    @Slot()
    def resetGame(self):
        """重置游戏"""
        print("Resetting game...")
        self._game_state = GameState.MENU
        self._score = 0
        self._snake_positions = [(self._grid_width // 2, self._grid_height // 2)]
        self._snake_direction = Direction.RIGHT
        self._next_direction = Direction.RIGHT
        self._snake_growing = 0
        
        self.game_timer.stop()
        self._spawn_food()
        
        # 发送信号
        self.gameStateChanged.emit(self._game_state.value)
        self.scoreChanged.emit(self._score)
        self.snakePositionsChanged.emit(self.snakePositions)
        self.foodPositionChanged.emit(self.foodPosition)
    
    @Slot(str)
    def setDirection(self, direction):
        """设置蛇的移动方向"""
        if self._game_state != GameState.PLAYING:
            return
        
        direction_map = {
            "up": Direction.UP,
            "down": Direction.DOWN,
            "left": Direction.LEFT,
            "right": Direction.RIGHT
        }
        
        new_direction = direction_map.get(direction.lower())
        if new_direction and self._is_valid_direction(new_direction):
            self._next_direction = new_direction
    
    def _is_valid_direction(self, direction):
        """检查方向是否有效（不能反向移动）"""
        if len(self._snake_positions) < 2:
            return True
        
        opposite_directions = {
            Direction.UP: Direction.DOWN,
            Direction.DOWN: Direction.UP,
            Direction.LEFT: Direction.RIGHT,
            Direction.RIGHT: Direction.LEFT
        }
        
        return direction != opposite_directions.get(self._snake_direction)
    
    def _spawn_food(self):
        """生成食物"""
        attempts = 0
        while attempts < 100:
            x = random.randint(1, self._grid_width - 2)
            y = random.randint(1, self._grid_height - 2)
            
            if (x, y) not in self._snake_positions:
                self._food_position = (x, y)
                self.foodPositionChanged.emit(self.foodPosition)
                print(f"Food spawned at: ({x}, {y})")
                break
            attempts += 1
    
    def update_game(self):
        """游戏主循环"""
        if self._game_state != GameState.PLAYING:
            return
        
        # 更新蛇的方向
        self._snake_direction = self._next_direction
        
        # 移动蛇
        head_x, head_y = self._snake_positions[0]
        dx, dy = self._snake_direction.value
        new_head = (head_x + dx, head_y + dy)
        
        # 根据游戏模式处理边界
        if self._game_mode == GameMode.FREESTYLE:
            # 自由模式：穿越边界
            new_head = (new_head[0] % self._grid_width, new_head[1] % self._grid_height)
        else:
            # 其他模式：边界碰撞
            if (new_head[0] < 0 or new_head[0] >= self._grid_width or 
                new_head[1] < 0 or new_head[1] >= self._grid_height):
                self._game_over()
                return
        
        # 检查自身碰撞
        if new_head in self._snake_positions:
            self._game_over()
            return
        
        # 移动蛇头
        self._snake_positions.insert(0, new_head)
        
        # 检查是否吃到食物
        if new_head == self._food_position:
            # 根据游戏模式计算分数
            score_multiplier = {
                GameMode.CLASSIC: 10,
                GameMode.MODERN: 15,
                GameMode.TIME_ATTACK: 20,
                GameMode.FREESTYLE: 12
            }
            
            points = score_multiplier.get(self._game_mode, 10) * self._difficulty
            self._score += points
            self._snake_growing += 1
            self._spawn_food()
            self.scoreChanged.emit(self._score)
            print(f"Food eaten! Score: {self._score} (+{points})")
        
        # 如果不需要增长，移除尾部
        if self._snake_growing > 0:
            self._snake_growing -= 1
        else:
            self._snake_positions.pop()
        
        # 发送蛇位置更新信号
        self.snakePositionsChanged.emit(self.snakePositions)
    
    def _game_over(self):
        """游戏结束"""
        print(f"Game Over! Final Score: {self._score}")
        self._game_state = GameState.GAME_OVER
        self.game_timer.stop()
        self.gameStateChanged.emit(self._game_state.value)

def main():
    print("Starting Full Snake Game...")
    app = QGuiApplication(sys.argv)
    
    # 创建游戏引擎
    game_engine = SnakeGame()
    
    # 创建QML引擎
    engine = QQmlApplicationEngine()
    
    # 注册Python对象到QML
    engine.rootContext().setContextProperty("gameEngine", game_engine)
    
    # 完整的QML代码
    qml_content = '''
import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: window
    width: 1000
    height: 700
    visible: true
    title: "贪吃蛇游戏 - 完整版"
    
    property string currentView: "menu"
    property string selectedMode: "classic"
    property int selectedDifficulty: 5
    
    Rectangle {
        anchors.fill: parent
        color: "#0C141E"
        focus: true
        
        Keys.onPressed: function(event) {
            if (window.currentView === "game") {
                switch(event.key) {
                    case Qt.Key_W:
                    case Qt.Key_Up:
                        gameEngine.setDirection("up")
                        break
                    case Qt.Key_S:
                    case Qt.Key_Down:
                        gameEngine.setDirection("down")
                        break
                    case Qt.Key_A:
                    case Qt.Key_Left:
                        gameEngine.setDirection("left")
                        break
                    case Qt.Key_D:
                    case Qt.Key_Right:
                        gameEngine.setDirection("right")
                        break
                    case Qt.Key_Space:
                        if (gameEngine.gameState === "menu") {
                            gameEngine.startGame()
                        } else if (gameEngine.gameState === "playing") {
                            gameEngine.pauseGame()
                        } else if (gameEngine.gameState === "paused") {
                            gameEngine.pauseGame()
                        }
                        break
                    case Qt.Key_R:
                        gameEngine.resetGame()
                        window.currentView = "menu"
                        break
                    case Qt.Key_Escape:
                        gameEngine.resetGame()
                        window.currentView = "menu"
                        break
                }
            }
            event.accepted = true
        }
        
        // 主菜单
        Rectangle {
            anchors.fill: parent
            visible: window.currentView === "menu"
            
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1A2332" }
                GradientStop { position: 1.0; color: "#0C141E" }
            }
            
            Column {
                anchors.centerIn: parent
                spacing: 40
                width: 600
                
                // 标题
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "贪吃蛇游戏"
                    font.pixelSize: 48
                    font.bold: true
                    color: "#50FF80"
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "现代化跨平台贪吃蛇游戏"
                    font.pixelSize: 16
                    color: "#AAAAAA"
                }
                
                // 游戏模式选择
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 500
                    height: 200
                    color: "#1A2332"
                    border.color: "#50FF80"
                    border.width: 2
                    radius: 10
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15
                        
                        Text {
                            text: "选择游戏模式"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#50FF80"
                        }
                        
                        Row {
                            spacing: 10
                            
                            // 经典模式
                            Rectangle {
                                width: 110
                                height: 60
                                color: window.selectedMode === "classic" ? "#50FF80" : "#2A3442"
                                border.color: "#50FF80"
                                border.width: 1
                                radius: 5
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "经典模式"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: window.selectedMode === "classic" ? "#000000" : "#FFFFFF"
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "传统玩法"
                                        font.pixelSize: 10
                                        color: window.selectedMode === "classic" ? "#333333" : "#AAAAAA"
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: window.selectedMode = "classic"
                                }
                            }
                            
                            // 现代模式
                            Rectangle {
                                width: 110
                                height: 60
                                color: window.selectedMode === "modern" ? "#50FF80" : "#2A3442"
                                border.color: "#50FF80"
                                border.width: 1
                                radius: 5
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "现代模式"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: window.selectedMode === "modern" ? "#000000" : "#FFFFFF"
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "更大地图"
                                        font.pixelSize: 10
                                        color: window.selectedMode === "modern" ? "#333333" : "#AAAAAA"
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: window.selectedMode = "modern"
                                }
                            }
                            
                            // 限时模式
                            Rectangle {
                                width: 110
                                height: 60
                                color: window.selectedMode === "time_attack" ? "#50FF80" : "#2A3442"
                                border.color: "#50FF80"
                                border.width: 1
                                radius: 5
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "限时模式"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: window.selectedMode === "time_attack" ? "#000000" : "#FFFFFF"
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "高分挑战"
                                        font.pixelSize: 10
                                        color: window.selectedMode === "time_attack" ? "#333333" : "#AAAAAA"
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: window.selectedMode = "time_attack"
                                }
                            }
                            
                            // 自由模式
                            Rectangle {
                                width: 110
                                height: 60
                                color: window.selectedMode === "freestyle" ? "#50FF80" : "#2A3442"
                                border.color: "#50FF80"
                                border.width: 1
                                radius: 5
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "自由模式"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: window.selectedMode === "freestyle" ? "#000000" : "#FFFFFF"
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "穿越边界"
                                        font.pixelSize: 10
                                        color: window.selectedMode === "freestyle" ? "#333333" : "#AAAAAA"
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: window.selectedMode = "freestyle"
                                }
                            }
                        }
                        
                        // 难度选择
                        Row {
                            spacing: 10
                            
                            Text {
                                text: "难度等级:"
                                font.pixelSize: 14
                                color: "#FFFFFF"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Row {
                                spacing: 5
                                Repeater {
                                    model: 10
                                    Rectangle {
                                        width: 25
                                        height: 25
                                        color: (index + 1) <= window.selectedDifficulty ? "#50FF80" : "#2A3442"
                                        border.color: "#50FF80"
                                        border.width: 1
                                        radius: 3
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: index + 1
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: (index + 1) <= window.selectedDifficulty ? "#000000" : "#FFFFFF"
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: window.selectedDifficulty = index + 1
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 开始游戏按钮
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 200
                    height: 50
                    color: "#50FF80"
                    radius: 25
                    
                    Text {
                        anchors.centerIn: parent
                        text: "开始游戏"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#000000"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("Starting game with mode:", window.selectedMode, "difficulty:", window.selectedDifficulty)
                            gameEngine.setGameMode(window.selectedMode, window.selectedDifficulty)
                            window.currentView = "game"
                        }
                    }
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "点击开始游戏按钮或按空格键开始"
                    font.pixelSize: 14
                    color: "#666666"
                }
            }
        }
        
        // 游戏界面
        Rectangle {
            anchors.fill: parent
            visible: window.currentView === "game"
            color: "#0C141E"
            
            Row {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // 游戏区域
                Rectangle {
                    width: parent.width - 250
                    height: parent.height
                    color: "#1A2332"
                    border.color: "#50FF80"
                    border.width: 3
                    radius: 10
                    
                    Canvas {
                        id: gameCanvas
                        anchors.fill: parent
                        anchors.margins: 3
                        
                        property real cellSize: Math.min(width / gameEngine.gridWidth, height / gameEngine.gridHeight)
                        property real offsetX: (width - gameEngine.gridWidth * cellSize) / 2
                        property real offsetY: (height - gameEngine.gridHeight * cellSize) / 2
                        
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            
                            // 绘制网格
                            ctx.strokeStyle = "#2A3442"
                            ctx.lineWidth = 1
                            
                            for (var x = 0; x <= gameEngine.gridWidth; x++) {
                                ctx.beginPath()
                                ctx.moveTo(offsetX + x * cellSize, offsetY)
                                ctx.lineTo(offsetX + x * cellSize, offsetY + gameEngine.gridHeight * cellSize)
                                ctx.stroke()
                            }
                            
                            for (var y = 0; y <= gameEngine.gridHeight; y++) {
                                ctx.beginPath()
                                ctx.moveTo(offsetX, offsetY + y * cellSize)
                                ctx.lineTo(offsetX + gameEngine.gridWidth * cellSize, offsetY + y * cellSize)
                                ctx.stroke()
                            }
                            
                            // 绘制蛇
                            var snakePositions = gameEngine.snakePositions
                            for (var i = 0; i < snakePositions.length; i++) {
                                var pos = snakePositions[i]
                                var x = offsetX + pos.x * cellSize
                                var y = offsetY + pos.y * cellSize
                                
                                ctx.fillStyle = i === 0 ? "#70FFAA" : "#50FF80"
                                ctx.fillRect(x + 1, y + 1, cellSize - 2, cellSize - 2)
                                
                                // 蛇头眼睛
                                if (i === 0) {
                                    ctx.fillStyle = "#000000"
                                    ctx.fillRect(x + cellSize * 0.3, y + cellSize * 0.3, 2, 2)
                                    ctx.fillRect(x + cellSize * 0.7, y + cellSize * 0.3, 2, 2)
                                }
                            }
                            
                            // 绘制食物
                            var food = gameEngine.foodPosition
                            var fx = offsetX + food.x * cellSize
                            var fy = offsetY + food.y * cellSize
                            
                            ctx.fillStyle = "#FF6464"
                            ctx.beginPath()
                            ctx.arc(fx + cellSize/2, fy + cellSize/2, cellSize/2 - 2, 0, 2 * Math.PI)
                            ctx.fill()
                        }
                        
                        Connections {
                            target: gameEngine
                            function onSnakePositionsChanged() {
                                gameCanvas.requestPaint()
                            }
                            function onFoodPositionChanged() {
                                gameCanvas.requestPaint()
                            }
                        }
                    }
                    
                    // 游戏状态提示
                    Rectangle {
                        anchors.centerIn: parent
                        width: 300
                        height: 120
                        color: "#80000000"
                        radius: 10
                        visible: gameEngine.gameState !== "playing"
                        
                        Column {
                            anchors.centerIn: parent
                            spacing: 10
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: {
                                    if (gameEngine.gameState === "menu") {
                                        return "按空格键开始游戏"
                                    } else if (gameEngine.gameState === "paused") {
                                        return "游戏暂停"
                                    } else if (gameEngine.gameState === "game_over") {
                                        return "游戏结束"
                                    }
                                    return ""
                                }
                                color: gameEngine.gameState === "game_over" ? "#FF6464" : "#50FF80"
                                font.pixelSize: 20
                                font.bold: true
                            }
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: {
                                    if (gameEngine.gameState === "menu") {
                                        return "WASD 或 方向键控制移动"
                                    } else if (gameEngine.gameState === "paused") {
                                        return "按空格键继续游戏"
                                    } else if (gameEngine.gameState === "game_over") {
                                        return "最终分数: " + gameEngine.score + "\\n按R键重新开始"
                                    }
                                    return ""
                                }
                                color: "#AAAAAA"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
                
                // 侧边栏
                Rectangle {
                    width: 230
                    height: parent.height
                    color: "#1A2332"
                    border.color: "#64C8FF"
                    border.width: 2
                    radius: 10
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20
                        
                        Text {
                            text: "游戏信息"
                            color: "#64C8FF"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#3A4A5A"
                        }
                        
                        Text {
                            text: "分数: " + gameEngine.score
                            color: "#50FF80"
                            font.pixelSize: 16
                            font.bold: true
                        }
                        
                        Text {
                            text: "长度: " + gameEngine.snakePositions.length
                            color: "#64C8FF"
                            font.pixelSize: 16
                        }
                        
                        Text {
                            text: "模式: " + gameEngine.gameMode
                            color: "#FFFFFF"
                            font.pixelSize: 14
                        }
                        
                        Text {
                            text: "难度: " + gameEngine.difficulty
                            color: "#FFFFFF"
                            font.pixelSize: 14
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#3A4A5A"
                        }
                        
                        Text {
                            text: "控制说明"
                            color: "#FFFFFF"
                            font.pixelSize: 16
                            font.bold: true
                        }
                        
                        Text {
                            text: "WASD / 方向键 - 移动\\n空格键 - 开始/暂停\\nR键 - 重新开始\\nESC键 - 返回菜单"
                            color: "#CCCCCC"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                        
                        Item { 
                            height: 20
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: "#FF6464"
                            radius: 20
                            
                            Text {
                                anchors.centerIn: parent
                                text: "返回菜单"
                                color: "#FFFFFF"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    gameEngine.resetGame()
                                    window.currentView = "menu"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
    '''
    
    # 加载QML
    engine.loadData(qml_content.encode())
    
    if not engine.rootObjects():
        print("Failed to load QML!")
        return 1
    
    print("Game started successfully!")
    return app.exec()

if __name__ == "__main__":
    sys.exit(main())