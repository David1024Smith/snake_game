import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Basic 2.15

ApplicationWindow {
    id: window
    width: 1280
    height: 720
    visible: true
    title: "贪吃蛇游戏"
    
    // 应用全局样式
    QtObject {
        id: globalStyle
        property color primaryColor: "#50FF80"
        property color secondaryColor: "#70FFAA"
        property color backgroundColor: "#1A2332"
        property color surfaceColor: "#2A3442"
        property color textColor: "#FFFFFF"
        property color accentColor: "#FF6464"
    }
    
    // 全局样式设置
    Button {
        id: styleControl
        visible: false
        
        background: Rectangle {
            color: styleControl.pressed ? "#AA4040" : (styleControl.hovered ? "#CC5050" : "#FF6060")
            radius: 8
            border.color: "#FF8080"
            border.width: 2
        }
        
        contentItem: Text {
            text: styleControl.text
            font.pixelSize: 14
            font.bold: true
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    
    // 游戏状态属性，避免循环引用
    property var _gameEngine: null
    property var _configManager: null
    property string currentView: "menu"
    
    // 整合的Component.onCompleted处理器
    Component.onCompleted: {
        console.log("Window completed, initializing...")
        
        // 连接游戏引擎
        console.log("Checking gameEngine...")
        // 直接存储，不使用双向绑定
        if (typeof gameEngine !== "undefined" && gameEngine !== null) {
            console.log("Game engine successfully connected!")
            _gameEngine = gameEngine
            _configManager = configManager
        } else {
            console.error("Game engine is null or undefined! Check Python initialization.")
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#0C141E"
        focus: true
        
        Keys.onPressed: function(event) {
            if (window.currentView === "game" && window._gameEngine) {
                switch(event.key) {
                    case Qt.Key_W:
                    case Qt.Key_Up:
                        window._gameEngine.setDirection("up")
                        break
                    case Qt.Key_S:
                    case Qt.Key_Down:
                        window._gameEngine.setDirection("down")
                        break
                    case Qt.Key_A:
                    case Qt.Key_Left:
                        window._gameEngine.setDirection("left")
                        break
                    case Qt.Key_D:
                    case Qt.Key_Right:
                        window._gameEngine.setDirection("right")
                        break
                    case Qt.Key_Space:
                        if (window._gameEngine.gameState === "menu") {
                            window._gameEngine.startGame()
                        } else if (window._gameEngine.gameState === "ready") {
                            console.log("Space pressed in READY state, starting game")
                            window._gameEngine.startGame()
                        } else if (window._gameEngine.gameState === "playing") {
                            window._gameEngine.pauseGame()
                        } else if (window._gameEngine.gameState === "paused") {
                            window._gameEngine.pauseGame()
                        }
                        break
                    case Qt.Key_R:
                        window._gameEngine.resetGame()
                        break
                    case Qt.Key_Escape:
                        window._gameEngine.resetGame()
                        window.currentView = "menu"
                        break
                }
            }
            event.accepted = true
        }
        
        // 主菜单
        MainMenu {
            id: mainMenu
            anchors.fill: parent
            visible: window.currentView === "menu"
            onStartGame: {
                if (window._gameEngine) {
                    window.currentView = "game"
                    window._gameEngine.startGame() // 这里会进入READY状态
                } else {
                    console.error("Cannot start game: gameEngine is null")
                }
            }
            onStartGameWithMode: function(mode, difficulty) {
                console.log("Starting game with mode:", mode, "difficulty:", difficulty)
                if (window._gameEngine) {
                    window._gameEngine.setGameMode(mode, difficulty)
                    window.currentView = "game"
                    window._gameEngine.startGame() // 这里会进入READY状态
                } else {
                    console.error("Cannot start game: gameEngine is null")
                }
            }
            onShowSettings: {
                window.currentView = "settings"
            }
            onShowHighScores: {
                window.currentView = "highscores"
            }
            onShowAchievements: {
                window.currentView = "achievements"
            }
        }
        
        // 游戏界面
        GameView {
            id: gameView
            anchors.fill: parent
            visible: window.currentView === "game"
            gameEngine: window._gameEngine
            onBackToMenu: {
                window.currentView = "menu"
                if (window._gameEngine) {
                    window._gameEngine.resetGame()
                }
            }
        }
        
        // 设置界面
        SettingsView {
            id: settingsView
            anchors.fill: parent
            visible: window.currentView === "settings"
            configManager: window._configManager
            onBackToMenu: {
                window.currentView = "menu"
            }
        }
        
        // 高分界面
        HighScoresView {
            id: highScoresView
            anchors.fill: parent
            visible: window.currentView === "highscores"
            onBackToMenu: {
                window.currentView = "menu"
            }
        }
        
        // 成就界面
        AchievementsView {
            id: achievementsView
            anchors.fill: parent
            visible: window.currentView === "achievements"
            onBackToMenu: {
                window.currentView = "menu"
            }
        }
    }
}