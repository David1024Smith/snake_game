import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: settingsView
    color: "#0C141E"
    
    property var configManager
    signal backToMenu()
    
    // 背景渐变
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0C141E" }
            GradientStop { position: 1.0; color: "#1A2332" }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 30
        
        // 标题
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "游戏设置"
            font.pixelSize: 36
            font.weight: Font.Bold
            color: "#50FF80"
        }
        
        // 设置内容
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ColumnLayout {
                width: parent.width
                spacing: 25
                
                // 游戏设置
                GroupBox {
                    Layout.fillWidth: true
                    title: "游戏设置"
                    
                    background: Rectangle {
                        color: "#1E2A3A"
                        border.color: "#50FF80"
                        border.width: 2
                        radius: 10
                    }
                    
                    label: Text {
                        text: parent.title
                        color: "#50FF80"
                        font.pixelSize: 20
                        font.bold: true
                    }
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        
                        // 默认难度
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "默认难度:"
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                Layout.preferredWidth: 120
                            }
                            
                            Slider {
                                id: defaultDifficultySlider
                                Layout.fillWidth: true
                                from: 1
                                to: 10
                                value: 5
                                stepSize: 1
                                
                                background: Rectangle {
                                    x: defaultDifficultySlider.leftPadding
                                    y: defaultDifficultySlider.topPadding + defaultDifficultySlider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 4
                                    width: defaultDifficultySlider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#3A4A5A"
                                    
                                    Rectangle {
                                        width: defaultDifficultySlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#50FF80"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: defaultDifficultySlider.leftPadding + defaultDifficultySlider.visualPosition * (defaultDifficultySlider.availableWidth - width)
                                    y: defaultDifficultySlider.topPadding + defaultDifficultySlider.availableHeight / 2 - height / 2
                                    implicitWidth: 20
                                    implicitHeight: 20
                                    radius: 10
                                    color: "#50FF80"
                                    border.color: "#70FFAA"
                                    border.width: 2
                                }
                            }
                            
                            Text {
                                text: Math.round(defaultDifficultySlider.value)
                                color: "#50FF80"
                                font.pixelSize: 16
                                font.bold: true
                                Layout.preferredWidth: 30
                            }
                        }
                        
                        // 自动保存
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "自动保存:"
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                Layout.fillWidth: true
                            }
                            
                            Switch {
                                id: autoSaveSwitch
                                checked: true
                                
                                indicator: Rectangle {
                                    implicitWidth: 48
                                    implicitHeight: 26
                                    x: autoSaveSwitch.leftPadding
                                    y: parent.height / 2 - height / 2
                                    radius: 13
                                    color: autoSaveSwitch.checked ? "#50FF80" : "#3A4A5A"
                                    border.color: autoSaveSwitch.checked ? "#50FF80" : "#3A4A5A"
                                    
                                    Rectangle {
                                        x: autoSaveSwitch.checked ? parent.width - width : 0
                                        width: 26
                                        height: 26
                                        radius: 13
                                        color: autoSaveSwitch.down ? "#CCCCCC" : "#FFFFFF"
                                        border.color: "#AAAAAA"
                                        
                                        Behavior on x {
                                            NumberAnimation { duration: 200 }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 显示FPS
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "显示FPS:"
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                Layout.fillWidth: true
                            }
                            
                            Switch {
                                id: showFpsSwitch
                                checked: false
                                
                                indicator: Rectangle {
                                    implicitWidth: 48
                                    implicitHeight: 26
                                    x: showFpsSwitch.leftPadding
                                    y: parent.height / 2 - height / 2
                                    radius: 13
                                    color: showFpsSwitch.checked ? "#50FF80" : "#3A4A5A"
                                    border.color: showFpsSwitch.checked ? "#50FF80" : "#3A4A5A"
                                    
                                    Rectangle {
                                        x: showFpsSwitch.checked ? parent.width - width : 0
                                        width: 26
                                        height: 26
                                        radius: 13
                                        color: showFpsSwitch.down ? "#CCCCCC" : "#FFFFFF"
                                        border.color: "#AAAAAA"
                                        
                                        Behavior on x {
                                            NumberAnimation { duration: 200 }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 音频设置
                GroupBox {
                    Layout.fillWidth: true
                    title: "音频设置"
                    
                    background: Rectangle {
                        color: "#1E2A3A"
                        border.color: "#64C8FF"
                        border.width: 2
                        radius: 10
                    }
                    
                    label: Text {
                        text: parent.title
                        color: "#64C8FF"
                        font.pixelSize: 20
                        font.bold: true
                    }
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        
                        // 主音量
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "主音量:"
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                Layout.preferredWidth: 120
                            }
                            
                            Slider {
                                id: masterVolumeSlider
                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                value: 80
                                
                                background: Rectangle {
                                    x: masterVolumeSlider.leftPadding
                                    y: masterVolumeSlider.topPadding + masterVolumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 4
                                    width: masterVolumeSlider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#3A4A5A"
                                    
                                    Rectangle {
                                        width: masterVolumeSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#64C8FF"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: masterVolumeSlider.leftPadding + masterVolumeSlider.visualPosition * (masterVolumeSlider.availableWidth - width)
                                    y: masterVolumeSlider.topPadding + masterVolumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 20
                                    implicitHeight: 20
                                    radius: 10
                                    color: "#64C8FF"
                                    border.color: "#84E8FF"
                                    border.width: 2
                                }
                            }
                            
                            Text {
                                text: Math.round(masterVolumeSlider.value) + "%"
                                color: "#64C8FF"
                                font.pixelSize: 16
                                font.bold: true
                                Layout.preferredWidth: 40
                            }
                        }
                        
                        // 音效音量
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "音效音量:"
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                Layout.preferredWidth: 120
                            }
                            
                            Slider {
                                id: sfxVolumeSlider
                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                value: 70
                                
                                background: Rectangle {
                                    x: sfxVolumeSlider.leftPadding
                                    y: sfxVolumeSlider.topPadding + sfxVolumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 4
                                    width: sfxVolumeSlider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#3A4A5A"
                                    
                                    Rectangle {
                                        width: sfxVolumeSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#FF9864"
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: sfxVolumeSlider.leftPadding + sfxVolumeSlider.visualPosition * (sfxVolumeSlider.availableWidth - width)
                                    y: sfxVolumeSlider.topPadding + sfxVolumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 20
                                    implicitHeight: 20
                                    radius: 10
                                    color: "#FF9864"
                                    border.color: "#FFB884"
                                    border.width: 2
                                }
                            }
                            
                            Text {
                                text: Math.round(sfxVolumeSlider.value) + "%"
                                color: "#FF9864"
                                font.pixelSize: 16
                                font.bold: true
                                Layout.preferredWidth: 40
                            }
                        }
                        
                        // 背景音乐
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "背景音乐:"
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                Layout.fillWidth: true
                            }
                            
                            Switch {
                                id: musicSwitch
                                checked: true
                                
                                indicator: Rectangle {
                                    implicitWidth: 48
                                    implicitHeight: 26
                                    x: musicSwitch.leftPadding
                                    y: parent.height / 2 - height / 2
                                    radius: 13
                                    color: musicSwitch.checked ? "#64C8FF" : "#3A4A5A"
                                    border.color: musicSwitch.checked ? "#64C8FF" : "#3A4A5A"
                                    
                                    Rectangle {
                                        x: musicSwitch.checked ? parent.width - width : 0
                                        width: 26
                                        height: 26
                                        radius: 13
                                        color: musicSwitch.down ? "#CCCCCC" : "#FFFFFF"
                                        border.color: "#AAAAAA"
                                        
                                        Behavior on x {
                                            NumberAnimation { duration: 200 }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 控制设置
                GroupBox {
                    Layout.fillWidth: true
                    title: "控制设置"
                    
                    background: Rectangle {
                        color: "#1E2A3A"
                        border.color: "#FFDC64"
                        border.width: 2
                        radius: 10
                    }
                    
                    label: Text {
                        text: parent.title
                        color: "#FFDC64"
                        font.pixelSize: 20
                        font.bold: true
                    }
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 15
                        
                        Text {
                            text: "键位设置"
                            color: "#FFFFFF"
                            font.pixelSize: 16
                            font.bold: true
                        }
                        
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 10
                            columnSpacing: 20
                            
                            Text { text: "向上:"; color: "#CCCCCC"; font.pixelSize: 14 }
                            Text { text: "W / ↑"; color: "#FFDC64"; font.pixelSize: 14; font.bold: true }
                            
                            Text { text: "向下:"; color: "#CCCCCC"; font.pixelSize: 14 }
                            Text { text: "S / ↓"; color: "#FFDC64"; font.pixelSize: 14; font.bold: true }
                            
                            Text { text: "向左:"; color: "#CCCCCC"; font.pixelSize: 14 }
                            Text { text: "A / ←"; color: "#FFDC64"; font.pixelSize: 14; font.bold: true }
                            
                            Text { text: "向右:"; color: "#CCCCCC"; font.pixelSize: 14 }
                            Text { text: "D / →"; color: "#FFDC64"; font.pixelSize: 14; font.bold: true }
                            
                            Text { text: "暂停:"; color: "#CCCCCC"; font.pixelSize: 14 }
                            Text { text: "空格"; color: "#FFDC64"; font.pixelSize: 14; font.bold: true }
                            
                            Text { text: "重新开始:"; color: "#CCCCCC"; font.pixelSize: 14 }
                            Text { text: "R"; color: "#FFDC64"; font.pixelSize: 14; font.bold: true }
                        }
                    }
                }
            }
        }
        
        // 底部按钮
        RowLayout {
            Layout.fillWidth: true
            spacing: 20
            
            Button {
                Layout.fillWidth: true
                text: "重置设置"
                
                background: Rectangle {
                    color: parent.pressed ? "#CC5454" : "#FF6464"
                    radius: 8
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#FFFFFF"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    // 重置所有设置到默认值
                    defaultDifficultySlider.value = 5
                    autoSaveSwitch.checked = true
                    showFpsSwitch.checked = false
                    masterVolumeSlider.value = 80
                    sfxVolumeSlider.value = 70
                    musicSwitch.checked = true
                    console.log("设置已重置")
                }
            }
            
            Button {
                Layout.fillWidth: true
                text: "保存设置"
                
                background: Rectangle {
                    color: parent.pressed ? "#4A7A4A" : "#50FF80"
                    radius: 8
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#000000"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    // 保存设置逻辑
                    console.log("设置已保存")
                    settingsView.backToMenu()
                }
            }
        }
    }
} 