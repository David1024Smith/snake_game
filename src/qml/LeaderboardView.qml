import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: leaderboardView
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
            text: "排行榜"
            font.pixelSize: 36
            font.weight: Font.Bold
            color: "#50FF80"
        }
        
        // 排行榜内容
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#1E2A3A"
            radius: 15
            border.width: 2
            border.color: "#50FF80"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20
                
                // 排行榜标题栏
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        Layout.preferredWidth: 60
                        text: "排名"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: "#64C8FF"
                        horizontalAlignment: Text.AlignCenter
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: "玩家"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: "#64C8FF"
                    }
                    
                    Text {
                        Layout.preferredWidth: 100
                        text: "分数"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: "#64C8FF"
                        horizontalAlignment: Text.AlignCenter
                    }
                    
                    Text {
                        Layout.preferredWidth: 120
                        text: "日期"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: "#64C8FF"
                        horizontalAlignment: Text.AlignCenter
                    }
                }
                
                // 分隔线
                Rectangle {
                    Layout.fillWidth: true
                    height: 2
                    color: "#3A4A5A"
                }
                
                // 排行榜列表
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ListView {
                        id: leaderboardList
                        model: ListModel {
                            ListElement { rank: 1; player: "玩家1"; score: 1250; date: "2024-01-15" }
                            ListElement { rank: 2; player: "玩家2"; score: 980; date: "2024-01-14" }
                            ListElement { rank: 3; player: "玩家3"; score: 750; date: "2024-01-13" }
                            ListElement { rank: 4; player: "玩家4"; score: 620; date: "2024-01-12" }
                            ListElement { rank: 5; player: "玩家5"; score: 540; date: "2024-01-11" }
                            ListElement { rank: 6; player: "玩家6"; score: 480; date: "2024-01-10" }
                            ListElement { rank: 7; player: "玩家7"; score: 420; date: "2024-01-09" }
                            ListElement { rank: 8; player: "玩家8"; score: 380; date: "2024-01-08" }
                            ListElement { rank: 9; player: "玩家9"; score: 320; date: "2024-01-07" }
                            ListElement { rank: 10; player: "玩家10"; score: 280; date: "2024-01-06" }
                        }
                        
                        delegate: Rectangle {
                            width: leaderboardList.width
                            height: 50
                            color: index % 2 === 0 ? "#2A3A4A" : "#1E2A3A"
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10
                                
                                // 排名
                                Rectangle {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 30
                                    radius: 15
                                    color: {
                                        if (rank === 1) return "#FFD700"  // 金色
                                        if (rank === 2) return "#C0C0C0"  // 银色
                                        if (rank === 3) return "#CD7F32"  // 铜色
                                        return "#64C8FF"
                                    }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: rank
                                        font.pixelSize: 14
                                        font.weight: Font.Bold
                                        color: rank <= 3 ? "#000000" : "#FFFFFF"
                                    }
                                }
                                
                                // 玩家名
                                Text {
                                    Layout.fillWidth: true
                                    text: player
                                    font.pixelSize: 16
                                    color: "#FFFFFF"
                                    elide: Text.ElideRight
                                }
                                
                                // 分数
                                Text {
                                    Layout.preferredWidth: 80
                                    text: score
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                    color: "#50FF80"
                                    horizontalAlignment: Text.AlignCenter
                                }
                                
                                // 日期
                                Text {
                                    Layout.preferredWidth: 100
                                    text: date
                                    font.pixelSize: 14
                                    color: "#AAAAAA"
                                    horizontalAlignment: Text.AlignCenter
                                }
                            }
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
                text: "清空记录"
                
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
                    // 清空排行榜逻辑
                    console.log("清空排行榜")
                }
            }
            
            Button {
                Layout.fillWidth: true
                text: "返回菜单"
                
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
                
                onClicked: leaderboardView.backToMenu()
            }
        }
    }
} 