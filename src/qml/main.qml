import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    width: 1280
    height: 720
    visible: true
    title: "贪吃蛇游戏"
    
    property string currentView: "menu"
    
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
        MainMenu {
            anchors.fill: parent
            visible: window.currentView === "menu"
            onStartGame: {
                window.currentView = "game"
                gameEngine.startGame()
            }
            onShowSettings: {
                window.currentView = "settings"
            }
            onShowHighScores: {
                window.currentView = "highscores"
            }
        }
        
        // 游戏界面
        GameView {
            anchors.fill: parent
            visible: window.currentView === "game"
            onBackToMenu: {
                window.currentView = "menu"
                gameEngine.resetGame()
            }
        }
        
        // 设置界面
        SettingsView {
            anchors.fill: parent
            visible: window.currentView === "settings"
            onBackToMenu: {
                window.currentView = "menu"
            }
        }
        
        // 高分界面
        HighScoresView {
            anchors.fill: parent
            visible: window.currentView === "highscores"
            onBackToMenu: {
                window.currentView = "menu"
            }
        }
    }
}