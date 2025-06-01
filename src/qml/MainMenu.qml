import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: mainMenu
    color: "#1A2332"
    
    signal startGame()
    signal showSettings()
    signal showHighScores()
    
    // 背景粒子效果
    ParticleBackground {
        anchors.fill: parent
    }
    
    Column {
        anchors.centerIn: parent
        spacing: 40
        
        // 游戏标题
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "贪吃蛇游戏"
            font.pixelSize: 64
            font.bold: true
            color: "#50FF80"
            style: Text.Outline
            styleColor: "#2A4A3A"
        }
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Snake Game"
            font.pixelSize: 24
            color: "#70FFAA"
            opacity: 0.8
        }
        
        // 菜单按钮
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            
            Button {
                id: startButton
                text: "开始游戏"
                width: 200
                height: 50
                
                background: Rectangle {
                    color: startButton.pressed ? "#40AA60" : (startButton.hovered ? "#50CC70" : "#50FF80")
                    radius: 8
                    border.color: "#70FFAA"
                    border.width: 2
                }
                
                contentItem: Text {
                    text: startButton.text
                    font.pixelSize: 18
                    font.bold: true
                    color: "#0C141E"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: mainMenu.startGame()
            }
            
            Button {
                id: settingsButton
                text: "设置"
                width: 200
                height: 50
                
                background: Rectangle {
                    color: settingsButton.pressed ? "#3A5A7A" : (settingsButton.hovered ? "#4A6A8A" : "#5A7A9A")
                    radius: 8
                    border.color: "#7A9ABA"
                    border.width: 2
                }
                
                contentItem: Text {
                    text: settingsButton.text
                    font.pixelSize: 18
                    font.bold: true
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: mainMenu.showSettings()
            }
            
            Button {
                id: scoresButton
                text: "排行榜"
                width: 200
                height: 50
                
                background: Rectangle {
                    color: scoresButton.pressed ? "#7A5A3A" : (scoresButton.hovered ? "#8A6A4A" : "#9A7A5A")
                    radius: 8
                    border.color: "#BA9A7A"
                    border.width: 2
                }
                
                contentItem: Text {
                    text: scoresButton.text
                    font.pixelSize: 18
                    font.bold: true
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: mainMenu.showHighScores()
            }
            
            Button {
                id: exitButton
                text: "退出游戏"
                width: 200
                height: 50
                
                background: Rectangle {
                    color: exitButton.pressed ? "#AA4040" : (exitButton.hovered ? "#CC5050" : "#FF6060")
                    radius: 8
                    border.color: "#FF8080"
                    border.width: 2
                }
                
                contentItem: Text {
                    text: exitButton.text
                    font.pixelSize: 18
                    font.bold: true
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: Qt.quit()
            }
        }
    }
    
    // 版本信息
    Text {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20
        text: "v1.0.0"
        font.pixelSize: 14
        color: "#70FFAA"
        opacity: 0.6
    }
} 