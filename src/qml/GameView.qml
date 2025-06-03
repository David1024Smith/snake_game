import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: gameView
    color: "#0C141E"
    
    // 添加属性变化监听，确保后续更新正确传递
    property var gameEngine: null
    onGameEngineChanged: {
        if (gameEngine !== null) {
            console.log("GameView received gameEngine:", gameEngine)
        }
    }
    
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
            gameEngine: gameView.gameEngine
        }
        
        // 游戏状态覆盖层
        Rectangle {
            anchors.fill: gameRenderer
            color: "transparent"
            visible: gameView.gameEngine !== null && 
                     (gameView.gameEngine.gameState === "paused" || 
                      gameView.gameEngine.gameState === "game_over" ||
                      gameView.gameEngine.gameState === "ready")
            
            Rectangle {
                id: gameStatusPanel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 50
                width: 400
                height: 320
                color: "#1A2332"
                radius: 12
                border.color: "#50FF80"
                border.width: 2
                opacity: 0.95
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    // 状态标题
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: {
                            if (!gameView.gameEngine || !gameView.gameEngine.gameState) return "";
                            
                            switch(gameView.gameEngine.gameState) {
                                case "paused": return "游戏暂停";
                                case "game_over": return "游戏结束";
                                case "ready": return "准备开始";
                                default: return "";
                            }
                        }
                        font.pixelSize: 24
                        font.bold: true
                        color: "#50FF80"
                    }
                    
                    // 状态描述
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: {
                            if (!gameView.gameEngine || !gameView.gameEngine.gameState) return "";
                            
                            switch(gameView.gameEngine.gameState) {
                                case "ready": return "按空格键开始游戏";
                                case "paused": return "按空格键继续";
                                case "game_over": return gameView.gameEngine.score !== undefined ? 
                                                  "最终分数: " + gameView.gameEngine.score : "";
                                default: return "";
                            }
                        }
                        font.pixelSize: 16
                        color: "#70FFAA"
                    }
                    
                    // 分隔线
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        Layout.topMargin: 10
                        Layout.bottomMargin: 10
                        color: "#50FF80"
                        opacity: 0.5
                    }
                    
                    // 游戏功能区域
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "游戏功能"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#50FF80"
                    }
                    
                    // 快速难度调整
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        spacing: 10
                        
                        Text {
                            text: "难度:"
                            font.pixelSize: 14
                            color: "#FFFFFF"
                        }
                        
                        Button {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            text: "-"
                            enabled: gameView.gameEngine !== null && gameView.gameEngine.difficulty > 1
                            
                            onClicked: {
                                if (gameView.gameEngine && gameView.gameEngine.difficulty > 1) {
                                    var newDifficulty = gameView.gameEngine.difficulty - 1
                                    if (typeof configManager !== "undefined" && configManager !== null) {
                                        configManager.currentDifficulty = newDifficulty
                                    }
                                }
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#3A8A50" : (parent.hovered ? "#50C080" : "#50FF80")
                                radius: 4
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 16
                                font.bold: true
                                color: "#000000"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        Text {
                            Layout.fillWidth: true
                            text: gameView.gameEngine !== null ? 
                                  "等级 " + gameView.gameEngine.difficulty : "等级 5"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#50FF80"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        Button {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            text: "+"
                            enabled: gameView.gameEngine !== null && gameView.gameEngine.difficulty < 10
                            
                            onClicked: {
                                if (gameView.gameEngine && gameView.gameEngine.difficulty < 10) {
                                    var newDifficulty = gameView.gameEngine.difficulty + 1
                                    if (typeof configManager !== "undefined" && configManager !== null) {
                                        configManager.currentDifficulty = newDifficulty
                                    }
                                }
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#3A8A50" : (parent.hovered ? "#50C080" : "#50FF80")
                                radius: 4
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 16
                                font.bold: true
                                color: "#000000"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    
                    // 分隔线
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        Layout.topMargin: 5
                        Layout.bottomMargin: 5
                        color: "#50FF80"
                        opacity: 0.3
                    }
                    
                    // 主要操作按钮
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 5
                        spacing: 15
                        visible: gameView.gameEngine !== null && 
                                 (gameView.gameEngine.gameState === "paused" || 
                                  gameView.gameEngine.gameState === "game_over")
                        
                        Button {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 35
                            text: gameView.gameEngine !== null && gameView.gameEngine.gameState === "paused" ? "继续" : "重新开始"
                            onClicked: {
                                if (gameView.gameEngine !== null) {
                                    if (gameView.gameEngine.gameState === "paused") {
                                        gameView.gameEngine.pauseGame()
                                    } else {
                                        gameView.gameEngine.resetGame()
                                        gameView.gameEngine.startGame()
                                    }
                                }
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#3A8A50" : (parent.hovered ? "#50C080" : "#50FF80")
                                radius: 6
                                border.color: "#70FFAA"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                font.bold: true
                                color: "#000000"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        Button {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 35
                            text: "设置"
                            onClicked: {
                                // 返回主菜单并打开设置
                                gameView.backToMenu()
                                // 这里可以添加信号来直接打开设置界面
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#5A5A8A" : (parent.hovered ? "#7070AA" : "#8080CC")
                                radius: 6
                                border.color: "#9090DD"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                font.bold: true
                                color: "#FFFFFF"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        Button {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 35
                            text: "返回菜单"
                            onClicked: gameView.backToMenu()
                            
                            background: Rectangle {
                                color: parent.pressed ? "#AA4040" : (parent.hovered ? "#CC5050" : "#FF6060")
                                radius: 6
                                border.color: "#FF8080"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                font.bold: true
                                color: "#FFFFFF"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    
                    // 在ready状态下显示的提示
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 10
                        spacing: 10
                        visible: gameView.gameEngine !== null && gameView.gameEngine.gameState === "ready"
                        
                        // 提示图标或文字
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 40
                            color: "#2A3A4A"
                            radius: 6
                            border.color: "#50FF80"
                            border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: "[Space]"
                                font.pixelSize: 18
                                color: "#50FF80"
                                font.bold: true
                            }
                            
                            // 呼吸动画效果
                            SequentialAnimation {
                                running: gameView.gameEngine !== null && gameView.gameEngine.gameState === "ready"
                                loops: Animation.Infinite
                                NumberAnimation {
                                    target: parent
                                    property: "opacity"
                                    from: 0.5
                                    to: 1.0
                                    duration: 800
                                    easing.type: Easing.InOutQuad
                                }
                                NumberAnimation {
                                    target: parent
                                    property: "opacity"
                                    from: 1.0
                                    to: 0.5
                                    duration: 800
                                    easing.type: Easing.InOutQuad
                                }
                            }
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
                        text: gameView.gameEngine !== null && gameView.gameEngine.score !== undefined ? 
                              gameView.gameEngine.score : "0"
                        font.pixelSize: 32
                        font.bold: true
                        color: "#50FF80"
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "等级: " + (gameView.gameEngine !== null && gameView.gameEngine.level !== undefined ? 
                              gameView.gameEngine.level : "1")
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
                        text: "蛇长: " + (gameView.gameEngine !== null && gameView.gameEngine.snakeLength !== undefined ? 
                              gameView.gameEngine.snakeLength : "1")
                        font.pixelSize: 12
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: "食物数: " + (gameView.gameEngine !== null && gameView.gameEngine.foodCount !== undefined ? 
                              gameView.gameEngine.foodCount : "0")
                        font.pixelSize: 12
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: "游戏时间: " + (gameView.gameEngine !== null && gameView.gameEngine.gameTime !== undefined ? 
                              Math.floor(gameView.gameEngine.gameTime / 1000) + "s" : "0s")
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