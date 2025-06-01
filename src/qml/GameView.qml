import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: gameView
    color: "#0C141E"
    
    signal backToMenu()
    
    // 游戏区域
    Rectangle {
        id: gameArea
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width - sidePanel.width
        color: "#0C141E"
        
        // 游戏渲染器
        GameRenderer {
            id: gameRenderer
            anchors.centerIn: parent
            width: Math.min(parent.width - 40, 800)
            height: Math.min(parent.height - 40, 600)
        }
        
        // 游戏状态覆盖层
        Rectangle {
            anchors.fill: gameRenderer
            color: "transparent"
            visible: gameEngine ? (gameEngine.gameState === "paused" || gameEngine.gameState === "game_over") : false
            
            Rectangle {
                anchors.centerIn: parent
                width: 300
                height: 200
                color: "#1A2332"
                radius: 10
                border.color: "#50FF80"
                border.width: 2
                opacity: 0.95
                
                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: gameEngine ? (gameEngine.gameState === "paused" ? "游戏暂停" : "游戏结束") : ""
                        font.pixelSize: 24
                        font.bold: true
                        color: "#50FF80"
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: gameEngine && gameEngine.gameState === "game_over" ? "最终分数: " + gameEngine.score : "按空格键继续"
                        font.pixelSize: 16
                        color: "#70FFAA"
                    }
                    
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20
                        
                        Button {
                            text: gameEngine && gameEngine.gameState === "paused" ? "继续" : "重新开始"
                            onClicked: {
                                if (gameEngine.gameState === "paused") {
                                    gameEngine.pauseGame()
                                } else {
                                    gameEngine.resetGame()
                                    gameEngine.startGame()
                                }
                            }
                        }
                        
                        Button {
                            text: "返回菜单"
                            onClicked: gameView.backToMenu()
                        }
                    }
                }
            }
        }
    }
    
    // 侧边栏
    Rectangle {
        id: sidePanel
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 250
        color: "#1A2332"
        border.color: "#2A3A4A"
        border.width: 1
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20
            
            // 游戏信息
            Rectangle {
                width: parent.width
                height: 120
                color: "#2A3A4A"
                radius: 8
                
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "分数"
                        font.pixelSize: 16
                        color: "#70FFAA"
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: gameEngine ? gameEngine.score.toString() : "0"
                        font.pixelSize: 32
                        font.bold: true
                        color: "#50FF80"
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "等级: " + (gameEngine ? gameEngine.level.toString() : "1")
                        font.pixelSize: 14
                        color: "#70FFAA"
                    }
                }
            }
            
            // 控制说明
            Rectangle {
                width: parent.width
                height: 200
                color: "#2A3A4A"
                radius: 8
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 8
                    
                    Text {
                        text: "控制说明"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#50FF80"
                    }
                    
                    Text {
                        text: "WASD / 方向键: 移动"
                        font.pixelSize: 12
                        color: "#FFFFFF"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                    
                    Text {
                        text: "空格键: 暂停/继续"
                        font.pixelSize: 12
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: "R键: 重新开始"
                        font.pixelSize: 12
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: "ESC键: 返回菜单"
                        font.pixelSize: 12
                        color: "#FFFFFF"
                    }
                }
            }
            
            // 游戏统计
            Rectangle {
                width: parent.width
                height: 150
                color: "#2A3A4A"
                radius: 8
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 8
                    
                    Text {
                        text: "游戏统计"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#50FF80"
                    }
                    
                    Text {
                        text: "蛇长: " + (gameEngine ? gameEngine.snakeLength.toString() : "1")
                        font.pixelSize: 12
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: "食物数: " + (gameEngine ? gameEngine.foodCount.toString() : "0")
                        font.pixelSize: 12
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: "游戏时间: " + (gameEngine ? Math.floor(gameEngine.gameTime / 1000).toString() + "s" : "0s")
                        font.pixelSize: 12
                        color: "#FFFFFF"
                    }
                }
            }
            
            // 返回按钮
            Button {
                width: parent.width
                height: 40
                text: "返回菜单"
                
                background: Rectangle {
                    color: parent.pressed ? "#AA4040" : (parent.hovered ? "#CC5050" : "#FF6060")
                    radius: 8
                    border.color: "#FF8080"
                    border.width: 2
                }
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    font.bold: true
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: gameView.backToMenu()
            }
        }
    }
} 