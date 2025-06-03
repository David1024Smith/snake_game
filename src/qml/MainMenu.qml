import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: mainMenu
    color: "#0C141E"
    
    signal startGame()
    signal showSettings()
    signal showHighScores()
    signal showAchievements()
    signal startGameWithMode(string mode, int difficulty)
    
    property string selectedMode: "classic"
    // 绑定到configManager的当前难度，如果configManager不存在则使用默认值5
    property int selectedDifficulty: (typeof configManager !== "undefined" && configManager !== null) ? configManager.currentDifficulty : 5
    
    // 监听configManager的难度变化
    Connections {
        target: (typeof configManager !== "undefined" && configManager !== null) ? configManager : null
        function onDifficultyChanged(newDifficulty) {
            console.log("MainMenu: Difficulty changed to", newDifficulty)
            // selectedDifficulty会自动更新，因为它绑定到configManager.currentDifficulty
        }
    }
    
    // 统一的样式配置
    readonly property color primaryColor: "#50FF80"
    readonly property color secondaryColor: "#70FFAA"
    readonly property color backgroundColor: "#1A2332"
    readonly property color surfaceColor: "#2A3442"
    readonly property color textColor: "#FFFFFF"
    readonly property color textSecondaryColor: "#AAAAAA"
    readonly property color accentColor: "#FF6464"
    
    readonly property int titleFontSize: 42
    readonly property int subtitleFontSize: 16
    readonly property int buttonFontSize: 16
    readonly property int labelFontSize: 14
    readonly property int smallFontSize: 12
    
    readonly property int buttonWidth: 220
    readonly property int buttonHeight: 50
    readonly property int cardRadius: 12
    readonly property int buttonRadius: 8
    
    // 背景渐变
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#1A2332" }
        GradientStop { position: 1.0; color: "#0C141E" }
    }
    
    // 背景粒子效果
    ParticleBackground {
        anchors.fill: parent
        particleColor: mainMenu.primaryColor
    }
    
    // 主要内容区域
    Item {
        id: mainContent
        anchors.fill: parent
        
        // 游戏标题区域
        ColumnLayout {
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "贪吃蛇游戏"
                font.pixelSize: mainMenu.titleFontSize
                font.bold: true
                color: mainMenu.primaryColor
                style: Text.Outline
                styleColor: "#2A4A3A"
            }
            
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "现代化跨平台贪吃蛇游戏"
                font.pixelSize: mainMenu.subtitleFontSize
                color: mainMenu.secondaryColor
                opacity: 0.9
            }
        }
        
        // 游戏模式和功能选择区域
        Rectangle {
            id: modeSelectionCard
            anchors.centerIn: parent
            width: 480
            height: 400
            color: mainMenu.backgroundColor
            border.color: mainMenu.primaryColor
            border.width: 2
            radius: mainMenu.cardRadius
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "游戏模式"
                    font.pixelSize: 20
                    font.bold: true
                    color: mainMenu.primaryColor
                }
                
                // 游戏模式网格
                GridLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                    columns: 2
                    rowSpacing: 12
                    columnSpacing: 12
                    
                    // 经典模式
                    Rectangle {
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 70
                        color: mainMenu.selectedMode === "classic" ? mainMenu.primaryColor : mainMenu.surfaceColor
                        border.color: mainMenu.primaryColor
                        border.width: 2
                        radius: mainMenu.buttonRadius
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "经典模式"
                                font.pixelSize: mainMenu.labelFontSize
                                font.bold: true
                                color: mainMenu.selectedMode === "classic" ? "#000000" : mainMenu.textColor
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "传统玩法"
                                font.pixelSize: mainMenu.smallFontSize
                                color: mainMenu.selectedMode === "classic" ? "#333333" : mainMenu.textSecondaryColor
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: mainMenu.selectedMode = "classic"
                            onEntered: parent.scale = 1.05
                            onExited: parent.scale = 1.0
                        }
                        
                        Behavior on scale { NumberAnimation { duration: 150 } }
                    }
                    
                    // 现代模式
                    Rectangle {
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 70
                        color: mainMenu.selectedMode === "modern" ? mainMenu.primaryColor : mainMenu.surfaceColor
                        border.color: mainMenu.primaryColor
                        border.width: 2
                        radius: mainMenu.buttonRadius
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "现代模式"
                                font.pixelSize: mainMenu.labelFontSize
                                font.bold: true
                                color: mainMenu.selectedMode === "modern" ? "#000000" : mainMenu.textColor
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "更大地图"
                                font.pixelSize: mainMenu.smallFontSize
                                color: mainMenu.selectedMode === "modern" ? "#333333" : mainMenu.textSecondaryColor
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: mainMenu.selectedMode = "modern"
                            onEntered: parent.scale = 1.05
                            onExited: parent.scale = 1.0
                        }
                        
                        Behavior on scale { NumberAnimation { duration: 150 } }
                    }
                    
                    // 限时模式
                    Rectangle {
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 70
                        color: mainMenu.selectedMode === "time_attack" ? mainMenu.primaryColor : mainMenu.surfaceColor
                        border.color: mainMenu.primaryColor
                        border.width: 2
                        radius: mainMenu.buttonRadius
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "限时模式"
                                font.pixelSize: mainMenu.labelFontSize
                                font.bold: true
                                color: mainMenu.selectedMode === "time_attack" ? "#000000" : mainMenu.textColor
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "高分挑战"
                                font.pixelSize: mainMenu.smallFontSize
                                color: mainMenu.selectedMode === "time_attack" ? "#333333" : mainMenu.textSecondaryColor
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: mainMenu.selectedMode = "time_attack"
                            onEntered: parent.scale = 1.05
                            onExited: parent.scale = 1.0
                        }
                        
                        Behavior on scale { NumberAnimation { duration: 150 } }
                    }
                    
                    // 自由模式
                    Rectangle {
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 70
                        color: mainMenu.selectedMode === "freestyle" ? mainMenu.primaryColor : mainMenu.surfaceColor
                        border.color: mainMenu.primaryColor
                        border.width: 2
                        radius: mainMenu.buttonRadius
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "自由模式"
                                font.pixelSize: mainMenu.labelFontSize
                                font.bold: true
                                color: mainMenu.selectedMode === "freestyle" ? "#000000" : mainMenu.textColor
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "穿越边界"
                                font.pixelSize: mainMenu.smallFontSize
                                color: mainMenu.selectedMode === "freestyle" ? "#333333" : mainMenu.textSecondaryColor
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: mainMenu.selectedMode = "freestyle"
                            onEntered: parent.scale = 1.05
                            onExited: parent.scale = 1.0
                        }
                        
                        Behavior on scale { NumberAnimation { duration: 150 } }
                    }
                }
                
                // 分隔线
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    color: mainMenu.primaryColor
                    opacity: 0.5
                }
                
                // 功能按钮区域
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "游戏功能"
                    font.pixelSize: 20
                    font.bold: true
                    color: mainMenu.primaryColor
                }
                
                // 功能按钮行
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                    spacing: 15
                    
                    // 设置按钮
                    Rectangle {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 50
                        color: settingsMouseArea.pressed ? Qt.darker(mainMenu.surfaceColor, 1.3) : 
                              (settingsMouseArea.containsMouse ? Qt.lighter(mainMenu.surfaceColor, 1.2) : mainMenu.surfaceColor)
                        radius: mainMenu.buttonRadius
                        border.color: mainMenu.primaryColor
                        border.width: 2
                        
                        Text {
                            anchors.centerIn: parent
                            text: "设置"
                            font.pixelSize: mainMenu.buttonFontSize
                            font.bold: true
                            color: mainMenu.textColor
                        }
                        
                        MouseArea {
                            id: settingsMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: mainMenu.showSettings()
                            onEntered: parent.scale = 1.05
                            onExited: parent.scale = 1.0
                        }
                        
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    
                    // 排行榜按钮
                    Rectangle {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 50
                        color: scoresMouseArea.pressed ? Qt.darker(mainMenu.surfaceColor, 1.3) : 
                              (scoresMouseArea.containsMouse ? Qt.lighter(mainMenu.surfaceColor, 1.2) : mainMenu.surfaceColor)
                        radius: mainMenu.buttonRadius
                        border.color: mainMenu.primaryColor
                        border.width: 2
                        
                        Text {
                            anchors.centerIn: parent
                            text: "排行榜"
                            font.pixelSize: mainMenu.buttonFontSize
                            font.bold: true
                            color: mainMenu.textColor
                        }
                        
                        MouseArea {
                            id: scoresMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: mainMenu.showHighScores()
                            onEntered: parent.scale = 1.05
                            onExited: parent.scale = 1.0
                        }
                        
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    
                    // 成就按钮
                    Rectangle {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 50
                        color: achievementsMouseArea.pressed ? Qt.darker(mainMenu.surfaceColor, 1.3) : 
                              (achievementsMouseArea.containsMouse ? Qt.lighter(mainMenu.surfaceColor, 1.2) : mainMenu.surfaceColor)
                        radius: mainMenu.buttonRadius
                        border.color: mainMenu.primaryColor
                        border.width: 2
                        
                        Text {
                            anchors.centerIn: parent
                            text: "成就"
                            font.pixelSize: mainMenu.buttonFontSize
                            font.bold: true
                            color: mainMenu.textColor
                        }
                        
                        MouseArea {
                            id: achievementsMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: mainMenu.showAchievements()
                            onEntered: parent.scale = 1.05
                            onExited: parent.scale = 1.0
                        }
                        
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }
        }
        
        // 底部按钮区域
        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 60
            spacing: 40
            
            // 开始游戏按钮 - 主要按钮样式
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: mainMenu.buttonWidth
                Layout.preferredHeight: mainMenu.buttonHeight + 10
                color: startGameMouseArea.pressed ? Qt.darker(mainMenu.primaryColor, 1.2) : 
                       (startGameMouseArea.containsMouse ? Qt.lighter(mainMenu.primaryColor, 1.1) : mainMenu.primaryColor)
                radius: mainMenu.buttonRadius
                border.color: Qt.lighter(mainMenu.primaryColor, 1.2)
                border.width: 2
                
                Text {
                    anchors.centerIn: parent
                    text: "开始游戏"
                    font.pixelSize: mainMenu.buttonFontSize + 2
                    font.bold: true
                    color: "#000000"
                }
                
                MouseArea {
                    id: startGameMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        console.log("Starting game with mode:", mainMenu.selectedMode, "difficulty:", mainMenu.selectedDifficulty)
                        mainMenu.startGameWithMode(mainMenu.selectedMode, mainMenu.selectedDifficulty)
                    }
                    onEntered: parent.scale = 1.05
                    onExited: parent.scale = 1.0
                }
                
                Behavior on scale { NumberAnimation { duration: 150 } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            
            // 退出游戏按钮 - 危险操作样式
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: mainMenu.buttonWidth
                Layout.preferredHeight: mainMenu.buttonHeight
                color: exitMouseArea.pressed ? Qt.darker(mainMenu.accentColor, 1.3) : 
                       (exitMouseArea.containsMouse ? Qt.lighter(mainMenu.accentColor, 1.1) : mainMenu.accentColor)
                radius: mainMenu.buttonRadius
                border.color: Qt.lighter(mainMenu.accentColor, 1.2)
                border.width: 2
                
                Text {
                    anchors.centerIn: parent
                    text: "退出游戏"
                    font.pixelSize: mainMenu.buttonFontSize
                    font.bold: true
                    color: mainMenu.textColor
                }
                
                MouseArea {
                    id: exitMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Qt.quit()
                    onEntered: parent.scale = 1.05
                    onExited: parent.scale = 1.0
                }
                
                Behavior on scale { NumberAnimation { duration: 150 } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
        
        // 提示文本
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            text: "使用方向键或WASD控制，空格键暂停 | 难度设置请进入设置菜单"
            font.pixelSize: mainMenu.smallFontSize
            color: mainMenu.textSecondaryColor
            opacity: 0.8
        }
        
        // 版本信息
        Text {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 20
            text: "v3.0.0"
            font.pixelSize: mainMenu.smallFontSize
            color: mainMenu.secondaryColor
            opacity: 0.7
        }
    }
} 