import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: achievementsView
    color: "#0C141E"
    
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
            text: "成就系统"
            font.pixelSize: 36
            font.weight: Font.Bold
            color: "#50FF80"
        }
        
        // 成就统计
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "#1E2A3A"
            radius: 10
            border.width: 2
            border.color: "#64C8FF"
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 30
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "已解锁成就"
                        font.pixelSize: 14
                        color: "#AAAAAA"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "8 / 12"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: "#50FF80"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
                
                Rectangle {
                    Layout.preferredWidth: 2
                    Layout.fillHeight: true
                    color: "#3A4A5A"
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "完成度"
                        font.pixelSize: 14
                        color: "#AAAAAA"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "67%"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: "#64C8FF"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
                
                Rectangle {
                    Layout.preferredWidth: 2
                    Layout.fillHeight: true
                    color: "#3A4A5A"
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "稀有成就"
                        font.pixelSize: 14
                        color: "#AAAAAA"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "2"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: "#FFD700"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
        
        // 成就列表
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            GridView {
                id: achievementsGrid
                cellWidth: 280
                cellHeight: 120
                
                model: ListModel {
                    ListElement { 
                        name: "初次游戏"
                        description: "完成第一局游戏"
                        icon: "🏆"
                        unlocked: true
                        progress: 100
                        rarity: "common"
                    }
                    ListElement { 
                        name: "百分达人"
                        description: "单局得分达到100分"
                        icon: "⭐"
                        unlocked: true
                        progress: 100
                        rarity: "common"
                    }
                    ListElement { 
                        name: "五百强者"
                        description: "单局得分达到500分"
                        icon: "🌟"
                        unlocked: true
                        progress: 100
                        rarity: "uncommon"
                    }
                    ListElement { 
                        name: "千分王者"
                        description: "单局得分达到1000分"
                        icon: "👑"
                        unlocked: false
                        progress: 75
                        rarity: "rare"
                    }
                    ListElement { 
                        name: "连击高手"
                        description: "达成10连击"
                        icon: "🔥"
                        unlocked: true
                        progress: 100
                        rarity: "uncommon"
                    }
                    ListElement { 
                        name: "连击大师"
                        description: "达成20连击"
                        icon: "💥"
                        unlocked: false
                        progress: 45
                        rarity: "rare"
                    }
                    ListElement { 
                        name: "道具大师"
                        description: "收集100个道具"
                        icon: "🎁"
                        unlocked: true
                        progress: 100
                        rarity: "uncommon"
                    }
                    ListElement { 
                        name: "生存专家"
                        description: "在生存模式中存活5分钟"
                        icon: "🛡️"
                        unlocked: false
                        progress: 20
                        rarity: "rare"
                    }
                    ListElement { 
                        name: "速度恶魔"
                        description: "在最高速度下得分200分"
                        icon: "⚡"
                        unlocked: true
                        progress: 100
                        rarity: "epic"
                    }
                    ListElement { 
                        name: "多人之王"
                        description: "赢得10场多人游戏"
                        icon: "🏅"
                        unlocked: false
                        progress: 30
                        rarity: "rare"
                    }
                    ListElement { 
                        name: "地图创造者"
                        description: "创建5个自定义地图"
                        icon: "🗺️"
                        unlocked: false
                        progress: 0
                        rarity: "uncommon"
                    }
                    ListElement { 
                        name: "完美主义者"
                        description: "解锁所有其他成就"
                        icon: "💎"
                        unlocked: false
                        progress: 67
                        rarity: "legendary"
                    }
                }
                
                delegate: Rectangle {
                    width: achievementsGrid.cellWidth - 10
                    height: achievementsGrid.cellHeight - 10
                    radius: 10
                    color: unlocked ? "#2A4A2A" : "#2A2A2A"
                    border.width: 2
                    border.color: {
                        if (rarity === "legendary") return "#FF00FF"
                        if (rarity === "epic") return "#A020F0"
                        if (rarity === "rare") return "#0080FF"
                        if (rarity === "uncommon") return "#00FF80"
                        return "#808080"
                    }
                    opacity: unlocked ? 1.0 : 0.6
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            // 成就图标
                            Text {
                                text: icon
                                font.pixelSize: 24
                                Layout.alignment: Qt.AlignTop
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                // 成就名称
                                Text {
                                    text: name
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                    color: unlocked ? "#FFFFFF" : "#888888"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                
                                // 稀有度标签
                                Rectangle {
                                    Layout.preferredWidth: rarityText.width + 8
                                    Layout.preferredHeight: 16
                                    radius: 8
                                    color: {
                                        if (rarity === "legendary") return "#FF00FF"
                                        if (rarity === "epic") return "#A020F0"
                                        if (rarity === "rare") return "#0080FF"
                                        if (rarity === "uncommon") return "#00FF80"
                                        return "#808080"
                                    }
                                    
                                    Text {
                                        id: rarityText
                                        anchors.centerIn: parent
                                        text: {
                                            if (rarity === "legendary") return "传说"
                                            if (rarity === "epic") return "史诗"
                                            if (rarity === "rare") return "稀有"
                                            if (rarity === "uncommon") return "罕见"
                                            return "普通"
                                        }
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                        color: "#FFFFFF"
                                    }
                                }
                            }
                        }
                        
                        // 成就描述
                        Text {
                            text: description
                            font.pixelSize: 12
                            color: unlocked ? "#CCCCCC" : "#666666"
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                        
                        // 进度条
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 6
                            radius: 3
                            color: "#333333"
                            visible: !unlocked
                            
                            Rectangle {
                                width: parent.width * (progress / 100)
                                height: parent.height
                                radius: parent.radius
                                color: parent.parent.parent.border.color
                            }
                        }
                        
                        // 进度文本
                        Text {
                            text: unlocked ? "已解锁" : progress + "%"
                            font.pixelSize: 10
                            color: unlocked ? "#50FF80" : "#AAAAAA"
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }
            }
        }
        
        // 返回按钮
        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            text: "返回菜单"
            
            background: Rectangle {
                color: parent.pressed ? "#4A7A4A" : "#50FF80"
                radius: 25
            }
            
            contentItem: Text {
                text: parent.text
                color: "#000000"
                font.pixelSize: 18
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: achievementsView.backToMenu()
        }
    }
} 