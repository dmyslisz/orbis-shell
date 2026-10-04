import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent

    signal proceed()

    Column {
        anchors.centerIn: parent
        spacing: 36

        // PS Controller silhouette graphic
        Item {
            width: 260
            height: 180
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                anchors.centerIn: parent
                width: 220
                height: 150
                source: "qrc:/assets/icons/boot_controllersetup1.png"
                fillMode: Image.PreserveAspectFit
                opacity: 0.95
            }

            // Glowing PS button circle indicator
            Rectangle {
                width: 26
                height: 26
                radius: 13
                color: "transparent"
                border.color: "#80d0ff"
                border.width: 2
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 16

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.25; duration: 900; easing.type: Easing.InOutSine }
                }
            }
        }

        // Welcome prompt text
        Column {
            spacing: 12
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "Press the PS button to use the controller."
                color: "#ffffff"
                font.pixelSize: 28
                font.weight: Font.Normal
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Press [Enter] / [Home] on keyboard or Guide on Gamepad"
                color: "#a0c0e8"
                font.pixelSize: 16
                font.weight: Font.Light
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }
        }
    }
}
