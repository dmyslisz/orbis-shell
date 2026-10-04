import QtQuick

Item {
    id: root
    anchors.fill: parent

    signal proceed()

    // Ambient radial pulse glow in background
    Rectangle {
        anchors.centerIn: parent
        width: 600
        height: 600
        radius: 300
        color: "#0a2860"
        opacity: 0.35

        SequentialAnimation on scale {
            loops: Animation.Infinite
            NumberAnimation { to: 1.15; duration: 2400; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.95; duration: 2400; easing.type: Easing.InOutSine }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 44

        // Console Gamepad silhouette graphic with pulsing Guide button
        Item {
            width: 300
            height: 200
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                anchors.centerIn: parent
                width: 250
                height: 170
                source: "qrc:/assets/icons/boot_controllersetup1.png"
                fillMode: Image.PreserveAspectFit
                opacity: 0.95
            }

            // Glowing Guide button circle indicator
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: "#1a4080"
                border.color: "#80d0ff"
                border.width: 2.5
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 16

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.25; duration: 800; easing.type: Easing.InOutSine }
                }

                // Inner pulsing light
                Rectangle {
                    anchors.centerIn: parent
                    width: 12
                    height: 12
                    radius: 6
                    color: "#ffffff"
                    opacity: 0.9
                }
            }
        }

        // Welcome prompt text
        Column {
            spacing: 14
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "Welcome to Orbis OS"
                color: "#ffffff"
                font.pixelSize: 36
                font.weight: Font.Normal
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Press the Guide button to use the controller."
                color: "#a8c8f0"
                font.pixelSize: 20
                font.weight: Font.Normal
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Press [Enter] / [Home] on keyboard or Guide on Gamepad"
                color: "#7090b8"
                font.pixelSize: 15
                font.weight: Font.Light
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.8
            }
        }

        // Bottom controller hints
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 32

            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    width: 22
                    height: 22
                    source: "qrc:/assets/icons/buttons/PS4_Cross.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Enter"
                    color: "#ffffff"
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
