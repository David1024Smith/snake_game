import QtQuick 2.15

Item {
    id: root
    
    property int particleCount: 50
    property color particleColor: "#50FF80"
    
    // 星星粒子
    Repeater {
        model: particleCount
        delegate: Rectangle {
            width: Math.random() * 3 + 1
            height: width
            radius: width / 2
            color: Qt.rgba(
                particleColor.r, 
                particleColor.g, 
                particleColor.b, 
                Math.random() * 0.5 + 0.2
            )
            x: Math.random() * root.width
            y: Math.random() * root.height
            
            // 闪烁动画
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation {
                    to: 0.2
                    duration: Math.random() * 2000 + 1000
                }
                NumberAnimation {
                    to: 1.0
                    duration: Math.random() * 2000 + 1000
                }
            }
            
            // 缓慢移动
            NumberAnimation on x {
                from: -10
                to: root.width + 10
                duration: Math.random() * 20000 + 30000
                loops: Animation.Infinite
            }
        }
    }
    
    // 浮动圆圈
    Repeater {
        model: particleCount / 2
        delegate: Rectangle {
            width: Math.random() * 20 + 10
            height: width
            radius: width / 2
            color: "transparent"
            border.color: Qt.rgba(
                particleColor.r, 
                particleColor.g, 
                particleColor.b, 
                Math.random() * 0.3 + 0.1
            )
            border.width: 1
            x: Math.random() * root.width
            y: Math.random() * root.height
            
            // 旋转动画
            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: Math.random() * 10000 + 5000
                loops: Animation.Infinite
            }
            
            // 上下浮动
            SequentialAnimation on y {
                loops: Animation.Infinite
                
                NumberAnimation {
                    to: Math.min(root.height - 50, y + Math.random() * 50 + 25)
                    duration: Math.random() * 3000 + 2000
                    easing.type: Easing.InOutSine
                }
                
                NumberAnimation {
                    to: Math.max(50, y - (Math.random() * 50 + 25))
                    duration: Math.random() * 3000 + 2000
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
} 