import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root
    
    // 通用属性
    property color particleColor: "#50FF80"
    property color dotWaveColor: "#92FCC1"
    
    // 粒子动画属性
    property int particleCount: 50
    
    // ---- 原始粒子动画 ----
    Item {
        id: particleAnimation
        anchors.fill: parent
        
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
    
    // ---- Point_Wave 动画 ----
    Item {
        id: pointWaveAnimation
        anchors.fill: parent
        width: parent.width
        height: parent.height
        
        property var dots: []
        property real dotRadius: 3.0
        property real r1: 0
        property real r2: 0
        property real spacing: 0
        property point centerPoint: Qt.point(width/2, height/2)
        
        Component.onCompleted: {
            initDots()
        }
        
        onWidthChanged: {
            initDots()
        }
        
        onHeightChanged: {
            initDots()
        }
        
        function initDots() {
            dots = []
            
            // 计算点之间的间距
            spacing = Math.min(width, height) / 20
            r2 = spacing
            
            // 计算水平和垂直方向上的点数
            var numCols = Math.ceil(width / spacing) + 1
            var numRows = Math.ceil(height / spacing) + 1
            
            // 计算起始位置，使点阵居中
            var startX = (width - (numCols - 1) * spacing) / 2
            var startY = (height - (numRows - 1) * spacing) / 2
            
            // 创建均匀分布的点阵
            for (var row = 0; row < numRows; ++row) {
                for (var col = 0; col < numCols; ++col) {
                    dots.push({
                        point: Qt.point(startX + col * spacing, startY + row * spacing),
                        radius: 3.0
                    })
                }
            }
        }
        
        // 判断点是否在环形区域内
        function isPointInAnnulus(testPoint, centerPoint, innerRadius, outerRadius) {
            var dx = testPoint.x - centerPoint.x
            var dy = testPoint.y - centerPoint.y
            var distance = Math.sqrt(dx * dx + dy * dy)
            return (distance >= innerRadius && distance <= outerRadius)
        }
        
        // 处理点的半径
        Timer {
            interval: 3
            running: true
            repeat: true
            onTriggered: {
                for (var i = 0; i < pointWaveAnimation.dots.length; i++) {
                    var dot = pointWaveAnimation.dots[i]
                    
                    if (pointWaveAnimation.isPointInAnnulus(
                            dot.point, 
                            pointWaveAnimation.centerPoint,
                            pointWaveAnimation.r1,
                            pointWaveAnimation.r2)) {
                        dot.radius += 0.75
                    } else {
                        if (dot.radius < 3) continue
                        dot.radius -= 0.3
                    }
                    
                    pointWaveAnimation.dots[i] = dot
                }
                
                if (pointWaveAnimation.r1 > pointWaveAnimation.width && pointWaveAnimation.r2 > 2) {
                    pointWaveAnimation.r1 = 0
                    pointWaveAnimation.r2 = pointWaveAnimation.spacing
                } else {
                    pointWaveAnimation.r1 += 1.0
                    pointWaveAnimation.r2 += 1.0
                }
                
                canvas.requestPaint()
            }
        }
        Canvas {
            id: canvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                
                // 绘制点
                ctx.fillStyle = dotWaveColor
                
                for (var i = 0; i < pointWaveAnimation.dots.length; i++) {
                    var dot = pointWaveAnimation.dots[i]
                    ctx.beginPath()
                    ctx.arc(dot.point.x, dot.point.y, dot.radius, 0, Math.PI * 2)
                    ctx.fill()
                }
                
                // 绘制波纹圆环
                ctx.strokeStyle = dotWaveColor
                ctx.lineWidth = 1
                ctx.beginPath()
                ctx.arc(pointWaveAnimation.centerPoint.x, pointWaveAnimation.centerPoint.y, 
                       pointWaveAnimation.r2, 0, Math.PI * 2)
                ctx.stroke()
                
                ctx.beginPath()
                ctx.arc(pointWaveAnimation.centerPoint.x, pointWaveAnimation.centerPoint.y, 
                       pointWaveAnimation.r1, 0, Math.PI * 2)
                ctx.stroke()
            }
        }
    }
} 