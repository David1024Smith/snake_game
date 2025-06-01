import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import "../styles"

Rectangle {
    id: card
    
    property string title: ""
    property string description: ""
    property string icon: ""
    property color color: ModernStyle.colors.primary
    property bool selected: false
    
    signal clicked()
    
    radius: ModernStyle.sizes.borderRadius
    color: ModernStyle.colors.surface
    border.width: selected ? 2 : 1
    border.color: selected ? card.color : ModernStyle.colors.surfaceLight
    
    // 悬停状态
    states: [
        State {
            name: "hovered"
            when: mouseArea.containsMouse
            PropertyChanges {
                target: card
                scale: 1.05
                border.width: 2
                border.color: card.color
            }
            PropertyChanges {
                target: glowEffect
                visible: true
            }
        }
    ]
    
    transitions: [
        Transition {
            PropertyAnimation {
                properties: "scale,border.width"
                duration: ModernStyle.animations.fast
                easing.type: ModernStyle.animations.easeOut
            }
            ColorAnimation {
                property: "border.color"
                duration: ModernStyle.animations.fast
            }
        }
    ]
    
    // 发光效果
    Rectangle {
        id: glowEffect
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: 4
        border.color: Qt.rgba(card.color.r, card.color.g, card.color.b, 0.3)
        visible: false
        
        layer.enabled: true
        layer.effect: Glow {
            radius: 12
            samples: 24
            color: card.color
            transparentBorder: true
            spread: 0.2
        }
    }
    
    // 背景渐变
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        opacity: 0.1
        gradient: Gradient {
            GradientStop { position: 0.0; color: card.color }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
    
    Column {
        anchors.centerIn: parent
        spacing: ModernStyle.sizes.spacingSmall
        
        // 图标
        Text {
            text: icon
            font.pixelSize: ModernStyle.fonts.huge
            anchors.horizontalCenter: parent.horizontalCenter
            
            // 图标动画
            SequentialAnimation {
                running: mouseArea.containsMouse
                loops: Animation.Infinite
                
                PropertyAnimation {
                    target: parent
                    property: "scale"
                    from: 1.0
                    to: 1.1
                    duration: 500
                    easing.type: Easing.InOutSine
                }
                
                PropertyAnimation {
                    target: parent
                    property: "scale"
                    from: 1.1
                    to: 1.0
                    duration: 500
                    easing.type: Easing.InOutSine
                }
            }
        }
        
        // 标题
        Text {
            text: title
            font.family: ModernStyle.fonts.family
            font.pixelSize: ModernStyle.fonts.large
            font.weight: Font.Medium
            color: ModernStyle.colors.textPrimary
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // 描述
        Text {
            text: description
            font.family: ModernStyle.fonts.family
            font.pixelSize: ModernStyle.fonts.small
            color: ModernStyle.colors.textSecondary
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            width: card.width - ModernStyle.sizes.paddingLarge * 2
            horizontalAlignment: Text.AlignHCenter
        }
    }
    
    // 选中指示器
    Rectangle {
        visible: selected
        width: 20
        height: 20
        radius: 10
        color: card.color
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: ModernStyle.sizes.spacingSmall
        
        Text {
            text: "✓"
            color: ModernStyle.colors.textPrimary
            font.pixelSize: 12
            font.weight: Font.Bold
            anchors.centerIn: parent
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            card.clicked()
            
            // 点击动画
            PropertyAnimation {
                target: card
                property: "scale"
                from: 1.05
                to: 0.95
                duration: 100
                easing.type: Easing.OutQuad
                
                onFinished: {
                    PropertyAnimation {
                        target: card
                        property: "scale"
                        from: 0.95
                        to: 1.05
                        duration: 100
                        easing.type: Easing.OutBounce
                    }.start()
                }
            }.start()
        }
    }
    
    // 阴影效果
    layer.enabled: true
    layer.effect: DropShadow {
        radius: mouseArea.containsMouse ? ModernStyle.shadows.large.radius : ModernStyle.shadows.medium.radius
        horizontalOffset: ModernStyle.shadows.medium.offsetX
        verticalOffset: ModernStyle.shadows.medium.offsetY
        color: ModernStyle.shadows.medium.color
        transparentBorder: true
        
        Behavior on radius {
            NumberAnimation { duration: ModernStyle.animations.fast }
        }
    }
} 