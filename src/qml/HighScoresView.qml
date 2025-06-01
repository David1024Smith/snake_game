import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    
    property var configManager
    
    signal backToMenu()
    
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0C141E" }
            GradientStop { position: 1.0; color: "#1A2332" }
        }
    }
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 30
        width: Math.min(parent.width * 0.8, 600)
        
        // 标题
        Text {
            text: "排行榜"
            font.pixelSize: 48
            font.bold: true
            color: "#50FF80"
            Layout.alignment: Qt.AlignHCenter
        }
        
        // 排行榜内容
        GroupBox {
            Layout.fillWidth: true
            title: "最高分记录"
            
            background: Rectangle {
                color: "transparent"
                border.color: "#64C8FF"
                border.width: 2
                radius: 10
            }
            
            label: Text {
                text: parent.title
                color: "#64C8FF"
                font.pixelSize: 18
                font.bold: true
            }
            
            ColumnLayout {
                width: parent.width
                spacing: 15
                
                // 游戏模式分数
                Repeater {
                    model: [
                        {mode: "classic", name: "经典模式"},
                        {mode: "maze", name: "迷宫模式"},
                        {mode: "freestyle", name: "自由模式"},
                        {mode: "time_attack", name: "限时模式"},
                        {mode: "survival", name: "生存模式"}
                    ]
                    
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        color: "#2A3442"
                        radius: 5
                        border.color: "#505A64"
                        border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            
                            Text {
                                text: modelData.name
                                color: "#FFFFFF"
                                font.pixelSize: 14
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: configManager ? configManager.getHighScore(modelData.mode) : "0"
                                color: "#50FF80"
                                font.pixelSize: 16
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
        
        // 返回按钮
        Button {
            text: "返回菜单"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 200
            Layout.preferredHeight: 50
            
            background: Rectangle {
                color: parent.pressed ? "#CC5454" : (parent.hovered ? "#EC7474" : "#FF6464")
                radius: 25
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
            
            onClicked: root.backToMenu()
        }
    }
} 