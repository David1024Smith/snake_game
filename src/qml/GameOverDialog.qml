import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Dialog {
    id: dialog
    
    property var gameEngine
    property var configManager
    
    signal restartGame()
    signal backToMenu()
    
    modal: true
    anchors.centerIn: parent
    width: 400
    height: 300
    
    background: Rectangle {
        color: "#1A2332"
        border.color: "#50FF80"
        border.width: 3
        radius: 15
        
        layer.enabled: true
        layer.effect: Glow {
            radius: 16
            samples: 33
            color: "#50FF80"
            transparentBorder: true
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20
        
        // 游戏结束标题
        Text {
            text: "游戏结束"
            font.pixelSize: 32
            font.bold: true
            color: "#FF6464"
            Layout.alignment: Qt.AlignHCenter
            
            layer.enabled: true
            layer.effect: Glow {
                radius: 8
                samples: 17
                color: "#FF6464"
                transparentBorder: true
            }
        }
        
        // 分数信息
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "transparent"
            border.color: "#64C8FF"
            border.width: 2
            radius: 10
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 5
                
                Text {
                    text: "最终分数"
                    font.pixelSize: 16
                    color: "#CCCCCC"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: gameEngine ? gameEngine.score : "0"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#50FF80"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
        
        // 统计信息
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 20
            rowSpacing: 10
            
            Text {
                text: "等级:"
                color: "#CCCCCC"
                font.pixelSize: 14
            }
            Text {
                text: gameEngine ? gameEngine.level : "1"
                color: "#64C8FF"
                font.pixelSize: 14
                font.bold: true
                Layout.alignment: Qt.AlignRight
            }
            
            Text {
                text: "最大长度:"
                color: "#CCCCCC"
                font.pixelSize: 14
            }
            Text {
                text: gameEngine ? gameEngine.snakePositions.length : "1"
                color: "#FF9864"
                font.pixelSize: 14
                font.bold: true
                Layout.alignment: Qt.AlignRight
            }
        }
        
        Item {
            Layout.fillHeight: true
        }
        
        // 按钮区域
        RowLayout {
            Layout.fillWidth: true
            spacing: 15
            
            Button {
                text: "重新开始"
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                
                background: Rectangle {
                    color: parent.pressed ? "#40DD70" : (parent.hovered ? "#60FF90" : "#50FF80")
                    radius: 22
                    border.color: "#FFFFFF"
                    border.width: 2
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 16
                    font.bold: true
                    color: "#0C141E"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    dialog.close()
                    dialog.restartGame()
                }
            }
            
            Button {
                text: "返回菜单"
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                
                background: Rectangle {
                    color: parent.pressed ? "#CC5454" : (parent.hovered ? "#EC7474" : "#FF6464")
                    radius: 22
                    border.color: "#FFFFFF"
                    border.width: 2
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 16
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    dialog.close()
                    dialog.backToMenu()
                }
            }
        }
    }
    
    // 保存最高分
    onOpened: {
        if (gameEngine && configManager) {
            // 这里可以添加保存最高分的逻辑
            // configManager.saveHighScore(currentMode, gameEngine.score)
        }
    }
} 