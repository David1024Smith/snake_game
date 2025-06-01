pragma Singleton
import QtQuick 2.15

QtObject {
    id: style
    
    // 颜色主题
    readonly property QtObject colors: QtObject {
        // 主色调
        readonly property color primary: "#6C5CE7"
        readonly property color primaryDark: "#5A4FCF"
        readonly property color primaryLight: "#A29BFE"
        
        // 次要色调
        readonly property color secondary: "#00CEC9"
        readonly property color secondaryDark: "#00B894"
        readonly property color secondaryLight: "#55EFC4"
        
        // 背景色
        readonly property color background: "#2D3436"
        readonly property color backgroundLight: "#636E72"
        readonly property color backgroundDark: "#1E2124"
        
        // 表面色
        readonly property color surface: "#36393F"
        readonly property color surfaceLight: "#40444B"
        readonly property color surfaceDark: "#2F3136"
        
        // 文本色
        readonly property color textPrimary: "#FFFFFF"
        readonly property color textSecondary: "#B2B2B2"
        readonly property color textDisabled: "#72767D"
        
        // 状态色
        readonly property color success: "#00B894"
        readonly property color warning: "#FDCB6E"
        readonly property color error: "#E17055"
        readonly property color info: "#74B9FF"
        
        // 游戏元素色
        readonly property color snake: "#00FF88"
        readonly property color snakeHead: "#00FF00"
        readonly property color food: "#FF6B6B"
        readonly property color powerUp: "#FFD93D"
        readonly property color obstacle: "#6C5CE7"
        
        // 特效色
        readonly property color glow: "#FFFFFF"
        readonly property color shadow: "#000000"
        readonly property color highlight: "#FFD700"
    }
    
    // 字体
    readonly property QtObject fonts: QtObject {
        readonly property string family: "Microsoft YaHei UI"
        readonly property string familyMono: "Consolas"
        
        readonly property int tiny: 10
        readonly property int small: 12
        readonly property int medium: 14
        readonly property int large: 16
        readonly property int xlarge: 20
        readonly property int xxlarge: 24
        readonly property int huge: 32
        readonly property int massive: 48
    }
    
    // 尺寸
    readonly property QtObject sizes: QtObject {
        readonly property int borderRadius: 8
        readonly property int borderRadiusLarge: 12
        readonly property int borderRadiusSmall: 4
        
        readonly property int spacing: 8
        readonly property int spacingLarge: 16
        readonly property int spacingSmall: 4
        
        readonly property int padding: 12
        readonly property int paddingLarge: 20
        readonly property int paddingSmall: 8
        
        readonly property int margin: 16
        readonly property int marginLarge: 24
        readonly property int marginSmall: 8
        
        readonly property int buttonHeight: 48
        readonly property int buttonHeightSmall: 36
        readonly property int buttonHeightLarge: 56
        
        readonly property int iconSize: 24
        readonly property int iconSizeSmall: 16
        readonly property int iconSizeLarge: 32
    }
    
    // 动画
    readonly property QtObject animations: QtObject {
        readonly property int fast: 150
        readonly property int normal: 250
        readonly property int slow: 400
        readonly property int verySlow: 600
        
        readonly property int easeInOut: Easing.InOutQuad
        readonly property int easeOut: Easing.OutQuad
        readonly property int easeIn: Easing.InQuad
        readonly property int bounce: Easing.OutBounce
        readonly property int elastic: Easing.OutElastic
    }
    
    // 阴影
    readonly property QtObject shadows: QtObject {
        readonly property QtObject small: QtObject {
            readonly property int radius: 4
            readonly property int offsetX: 0
            readonly property int offsetY: 2
            readonly property color color: Qt.rgba(0, 0, 0, 0.1)
        }
        
        readonly property QtObject medium: QtObject {
            readonly property int radius: 8
            readonly property int offsetX: 0
            readonly property int offsetY: 4
            readonly property color color: Qt.rgba(0, 0, 0, 0.15)
        }
        
        readonly property QtObject large: QtObject {
            readonly property int radius: 16
            readonly property int offsetX: 0
            readonly property int offsetY: 8
            readonly property color color: Qt.rgba(0, 0, 0, 0.2)
        }
    }
    
    // 渐变
    readonly property QtObject gradients: QtObject {
        readonly property Gradient primary: Gradient {
            GradientStop { position: 0.0; color: style.colors.primary }
            GradientStop { position: 1.0; color: style.colors.primaryDark }
        }
        
        readonly property Gradient secondary: Gradient {
            GradientStop { position: 0.0; color: style.colors.secondary }
            GradientStop { position: 1.0; color: style.colors.secondaryDark }
        }
        
        readonly property Gradient background: Gradient {
            GradientStop { position: 0.0; color: style.colors.backgroundDark }
            GradientStop { position: 1.0; color: style.colors.background }
        }
        
        readonly property Gradient surface: Gradient {
            GradientStop { position: 0.0; color: style.colors.surfaceLight }
            GradientStop { position: 1.0; color: style.colors.surface }
        }
        
        readonly property Gradient rainbow: Gradient {
            GradientStop { position: 0.0; color: "#FF6B6B" }
            GradientStop { position: 0.2; color: "#FFD93D" }
            GradientStop { position: 0.4; color: "#6BCF7F" }
            GradientStop { position: 0.6; color: "#4ECDC4" }
            GradientStop { position: 0.8; color: "#45B7D1" }
            GradientStop { position: 1.0; color: "#96CEB4" }
        }
    }
    
    // 游戏特定样式
    readonly property QtObject game: QtObject {
        readonly property int gridSize: 20
        readonly property int borderWidth: 2
        
        readonly property QtObject snake: QtObject {
            readonly property color body: "#00FF88"
            readonly property color head: "#00FF00"
            readonly property color bodyGlow: Qt.rgba(0, 1, 0.53, 0.3)
            readonly property color headGlow: Qt.rgba(0, 1, 0, 0.5)
            readonly property int glowRadius: 10
        }
        
        readonly property QtObject food: QtObject {
            readonly property color normal: "#FF6B6B"
            readonly property color golden: "#FFD700"
            readonly property color speed: "#00FFFF"
            readonly property color bonus: "#FF00FF"
            readonly property color mega: "#FF8000"
            readonly property int glowRadius: 8
        }
        
        readonly property QtObject powerUp: QtObject {
            readonly property color speedBoost: "#00FFFF"
            readonly property color slowMotion: "#8000FF"
            readonly property color invincibility: "#FFFF00"
            readonly property color doubleScore: "#FFD700"
            readonly property color magnet: "#FF69B4"
            readonly property color teleport: "#9400D3"
            readonly property color shrink: "#32CD32"
            readonly property color freezeTime: "#87CEEB"
            readonly property color shield: "#4169E1"
            readonly property color multiFood: "#FF1493"
            readonly property int glowRadius: 12
        }
        
        readonly property QtObject obstacle: QtObject {
            readonly property color wall: "#6C5CE7"
            readonly property color block: "#E17055"
            readonly property color destructible: "#FDCB6E"
        }
    }
    
    // 粒子效果
    readonly property QtObject particles: QtObject {
        readonly property int count: 50
        readonly property int lifeSpan: 3000
        readonly property int size: 4
        readonly property int sizeVariation: 2
        readonly property real velocity: 20
        readonly property real velocityVariation: 10
    }
    
    // 音效配置
    readonly property QtObject audio: QtObject {
        readonly property real masterVolume: 0.7
        readonly property real musicVolume: 0.5
        readonly property real effectVolume: 0.8
    }
    
    // 组件样式函数
    function buttonStyle(type) {
        switch(type) {
            case "primary":
                return {
                    background: colors.primary,
                    backgroundHover: colors.primaryLight,
                    backgroundPressed: colors.primaryDark,
                    text: colors.textPrimary,
                    border: "transparent"
                }
            case "secondary":
                return {
                    background: colors.secondary,
                    backgroundHover: colors.secondaryLight,
                    backgroundPressed: colors.secondaryDark,
                    text: colors.textPrimary,
                    border: "transparent"
                }
            case "outline":
                return {
                    background: "transparent",
                    backgroundHover: Qt.rgba(colors.primary.r, colors.primary.g, colors.primary.b, 0.1),
                    backgroundPressed: Qt.rgba(colors.primary.r, colors.primary.g, colors.primary.b, 0.2),
                    text: colors.primary,
                    border: colors.primary
                }
            case "ghost":
                return {
                    background: "transparent",
                    backgroundHover: Qt.rgba(colors.textPrimary.r, colors.textPrimary.g, colors.textPrimary.b, 0.05),
                    backgroundPressed: Qt.rgba(colors.textPrimary.r, colors.textPrimary.g, colors.textPrimary.b, 0.1),
                    text: colors.textPrimary,
                    border: "transparent"
                }
            default:
                return buttonStyle("primary")
        }
    }
    
    function cardStyle() {
        return {
            background: colors.surface,
            border: colors.surfaceLight,
            shadow: shadows.medium,
            radius: sizes.borderRadius
        }
    }
    
    function inputStyle() {
        return {
            background: colors.surfaceDark,
            backgroundFocus: colors.surface,
            border: colors.backgroundLight,
            borderFocus: colors.primary,
            text: colors.textPrimary,
            placeholder: colors.textSecondary
        }
    }
} 