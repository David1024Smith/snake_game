import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: testView
    color: "#0C141E"
    
    Text {
        anchors.centerIn: parent
        text: "Test View - Game Engine Working!"
        color: "#50FF80"
        font.pixelSize: 24
        font.bold: true
    }
    
    Button {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 50
        text: "Back to Menu"
        
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
            if (typeof stackView !== 'undefined') {
                stackView.pop()
            }
        }
    }
} 