import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button {
    id: control
    
    property string buttonType: "primary"
    property bool glowEffect: true
    property bool rippleEffect: true
    property color customColor: "transparent"
    property string iconSource: ""
    property int iconSize: ModernStyle.sizes.iconSize
    property bool loading: false
    
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                           implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                            implicitContentHeight + topPadding + bottomPadding,
                            ModernStyle.sizes.buttonHeight)
    
    leftPadding: ModernStyle.sizes.padding
    rightPadding: ModernStyle.sizes.padding
    topPadding: ModernStyle.sizes.paddingSmall
    bottomPadding: ModernStyle.sizes.paddingSmall
    
    font.family: ModernStyle.fonts.family
    font.pixelSize: ModernStyle.fonts.medium
    font.weight: Font.Medium
    
    property var styleConfig: customColor !== "transparent" ? 
        {
            background: customColor,
            backgroundHover: Qt.lighter(customColor, 1.1),
            backgroundPressed: Qt.darker(customColor, 1.1),
            text: ModernStyle.colors.textPrimary,
            border: "transparent"
        } : ModernStyle.buttonStyle(buttonType)
    
    background: Rectangle {
        id: backgroundRect
        
        implicitWidth: 100
        implicitHeight: ModernStyle.sizes.buttonHeight
        
        radius: ModernStyle.sizes.borderRadius
        color: control.enabled ? styleConfig.background : ModernStyle.colors.backgroundLight
        
        border.width: styleConfig.border !== "transparent" ? 2 : 0
        border.color: styleConfig.border
        
        // 渐变效果
        gradient: Gradient {
            GradientStop { 
                position: 0.0
                color: Qt.lighter(backgroundRect.color, 1.05)
            }
            GradientStop { 
                position: 1.0
                color: backgroundRect.color
            }
        }
        
        // 悬停状态
        states: [
            State {
                name: "hovered"
                when: control.hovered && !control.pressed
                PropertyChanges {
                    target: backgroundRect
                    color: control.enabled ? styleConfig.backgroundHover : ModernStyle.colors.backgroundLight
                }
            },
            State {
                name: "pressed"
                when: control.pressed
                PropertyChanges {
                    target: backgroundRect
                    color: control.enabled ? styleConfig.backgroundPressed : ModernStyle.colors.backgroundLight
                    scale: 0.98
                }
            }
        ]
        
        transitions: [
            Transition {
                PropertyAnimation {
                    properties: "color,scale"
                    duration: ModernStyle.animations.fast
                    easing.type: ModernStyle.animations.easeOut
                }
            }
        ]
        
        // 发光效果
        layer.enabled: glowEffect && control.enabled
        layer.effect: Glow {
            radius: 8
            samples: 16
            color: styleConfig.background
            transparentBorder: true
            spread: 0.2
        }
    }
    
    // 波纹效果
    Rectangle {
        id: ripple
        anchors.centerIn: parent
        width: 0
        height: 0
        radius: width / 2
        color: Qt.rgba(1, 1, 1, 0.3)
        visible: false
        
        PropertyAnimation {
            id: rippleAnimation
            target: ripple
            properties: "width,height"
            from: 0
            to: Math.max(control.width, control.height) * 2
            duration: ModernStyle.animations.normal
            easing.type: Easing.OutQuad
            
            onStarted: {
                ripple.visible = true
                ripple.opacity = 0.6
            }
            
            onFinished: {
                ripple.visible = false
                ripple.width = 0
                ripple.height = 0
            }
        }
        
        PropertyAnimation {
            id: rippleFadeOut
            target: ripple
            property: "opacity"
            from: 0.6
            to: 0
            duration: ModernStyle.animations.normal
            easing.type: Easing.OutQuad
        }
    }
    
    contentItem: Row {
        spacing: ModernStyle.sizes.spacingSmall
        
        // 图标
        Image {
            id: icon
            visible: iconSource !== ""
            source: iconSource
            width: iconSize
            height: iconSize
            anchors.verticalCenter: parent.verticalCenter
            
            ColorOverlay {
                anchors.fill: parent
                source: parent
                color: control.enabled ? styleConfig.text : ModernStyle.colors.textDisabled
            }
        }
        
        // 加载动画
        Rectangle {
            id: loadingIndicator
            visible: loading
            width: iconSize
            height: iconSize
            radius: width / 2
            color: "transparent"
            border.width: 2
            border.color: control.enabled ? styleConfig.text : ModernStyle.colors.textDisabled
            anchors.verticalCenter: parent.verticalCenter
            
            Rectangle {
                width: parent.width / 4
                height: parent.height / 4
                radius: width / 2
                color: parent.border.color
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                
                RotationAnimation {
                    target: loadingIndicator
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: loading
                }
            }
        }
        
        // 文本
        Text {
            text: control.text
            font: control.font
            color: control.enabled ? styleConfig.text : ModernStyle.colors.textDisabled
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
            visible: !loading
        }
    }
    
    // 点击效果
    onPressed: {
        if (rippleEffect) {
            rippleAnimation.start()
            rippleFadeOut.start()
        }
    }
    
    // 键盘焦点指示器
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: 2
        border.color: ModernStyle.colors.primary
        visible: control.activeFocus
        opacity: 0.6
        
        SequentialAnimation {
            running: control.activeFocus
            loops: Animation.Infinite
            
            PropertyAnimation {
                target: parent
                property: "opacity"
                from: 0.6
                to: 0.3
                duration: 800
            }
            
            PropertyAnimation {
                target: parent
                property: "opacity"
                from: 0.3
                to: 0.6
                duration: 800
            }
        }
    }
    
    // 禁用状态覆盖
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Qt.rgba(0, 0, 0, 0.3)
        visible: !control.enabled
    }
} 