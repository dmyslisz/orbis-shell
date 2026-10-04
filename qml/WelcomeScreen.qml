import QtQuick

Item {
    id: root
    anchors.fill: parent

    signal proceed()

    // Top-Left Orbis OS Wordmark & Emblem (Photo 1)
    Row {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 80
        anchors.topMargin: 56
        spacing: 16

        Image {
            width: 44
            height: 44
            source: "qrc:/assets/icons/launcher_logo.svg"
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "ORBIS OS"
            color: "#ffffff"
            font.pixelSize: 34
            font.weight: Font.DemiBold
            font.letterSpacing: 3
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Center Welcome Prompt (Photo 1)
    Column {
        anchors.centerIn: parent
        spacing: 18

        Text {
            text: "Welcome Back to Orbis OS"
            color: "#ffffff"
            font.pixelSize: 32
            font.weight: Font.Normal
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Press the Guide button to use the controller."
            color: "#b0d0f8"
            font.pixelSize: 20
            font.weight: Font.Light
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // Subtle keyboard / controller interaction hint at bottom
    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 48
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Press [Enter] or [Home] on keyboard / Guide button on controller"
        color: "#608cb8"
        font.pixelSize: 15
        font.weight: Font.Light
        opacity: 0.65
    }

    // Global click to proceed
    MouseArea {
        anchors.fill: parent
        onClicked: root.proceed()
    }
}
