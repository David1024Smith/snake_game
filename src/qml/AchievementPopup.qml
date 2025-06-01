import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Item {
    id: root
    width: 300
    height: 80
    
    function showAchievement(text) {
        achievementText.text = text
        showAnimation.start()
    }
    
    Rectangle {
        id: popup
        anchors.fill: parent
        color: "#1A2332"
        border.color: "#FFDC64"
        border.width: 2
        radius: 10
        opacity: 0
        scale: 0.8
        
        layer.enabled: true
        layer.effect: Glow {
            radius: 12
            samples: 25
            color: "#FFDC64"
            transparentBorder: true
        }
        
        Row {
            anchors.centerIn: parent
            spacing: 15
            
            // 成就图标
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: "#FFDC64"
                
                Text {
                    anchors.centerIn: parent
                    text: "🏆"
                    font.pixelSize: 24
                }
            }
            
            // 成就文本
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                
                Text {
                    text: "成就解锁！"
                    color: "#FFDC64"
                    font.pixelSize: 14
                    font.bold: true
                }
                
                Text {
                    id: achievementText
                    text: ""
                    color: "#FFFFFF"
                    font.pixelSize: 12
                }
            }
        }
    }
    
    // 显示动画
    SequentialAnimation {
        id: showAnimation
        
        ParallelAnimation {
            NumberAnimation {
                target: popup
                property: "opacity"
                to: 1
                duration: 300
                easing.type: Easing.OutQuart
            }
            NumberAnimation {
                target: popup
                property: "scale"
                to: 1
                duration: 300
                easing.type: Easing.OutBack
            }
        }
        
        PauseAnimation {
            duration: 3000
        }
        
        ParallelAnimation {
            NumberAnimation {
                target: popup
                property: "opacity"
                to: 0
                duration: 300
                easing.type: Easing.InQuart
            }
            NumberAnimation {
                target: popup
                property: "scale"
                to: 0.8
                duration: 300
                easing.type: Easing.InBack
            }
        }
    }
} 