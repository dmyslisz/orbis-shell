import QtQuick

Item {
    id: root
    anchors.fill: parent
    z: 2000
    visible: opacity > 0.001
    opacity: 0.0

    property string actionType: "" // "rest", "poweroff", "reboot", "close_shell"
    property bool isActive: false

    Behavior on opacity {
        NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
    }

    // Pitch black backdrop
    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Column {
        anchors.centerIn: parent
        spacing: 28
        width: 700

        // Animated Power Icon
        Item {
            width: 72
            height: 72
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: actionIcon
                anchors.centerIn: parent
                width: 60
                height: 60
                source: {
                    if (root.actionType === "rest") return "qrc:/assets/icons/rest_mode.svg";
                    if (root.actionType === "poweroff") return "qrc:/assets/icons/power.svg";
                    if (root.actionType === "reboot") return "qrc:/assets/icons/restart.svg";
                    return "qrc:/assets/icons/close_app.svg";
                }
                fillMode: Image.PreserveAspectFit

                // Rotation for reboot
                RotationAnimation on rotation {
                    running: root.isActive && root.actionType === "reboot"
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 1200
                }

                // Breathing pulse for rest and poweroff
                SequentialAnimation on opacity {
                    running: root.isActive && root.actionType !== "reboot"
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.35; duration: 750; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.35; to: 1.0; duration: 750; easing.type: Easing.InOutSine }
                }
            }
        }

        // Action Title
        Text {
            text: {
                if (root.actionType === "rest") return "Entering Rest Mode...";
                if (root.actionType === "poweroff") return "Turning Off System...";
                if (root.actionType === "reboot") return "Restarting System...";
                return "Closing Orbis OS Shell...";
            }
            color: "#ffffff"
            font.pixelSize: 28
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Subtitle Warning (PS4 style)
        Text {
            text: {
                if (root.actionType === "rest" || root.actionType === "poweroff")
                    return "Preparing to power down the system.\nDo not disconnect the AC power cord.";
                if (root.actionType === "reboot")
                    return "The system will restart shortly.";
                return "Exiting shell and returning to desktop session.";
            }
            color: "#90b4dc"
            font.pixelSize: 17
            font.weight: Font.Normal
            lineHeight: 1.3
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Timer {
        id: execTimer
        interval: 1800
        onTriggered: {
            if (root.actionType === "rest") {
                systemManager.enterRestMode();
            } else if (root.actionType === "poweroff") {
                systemManager.turnOff();
            } else if (root.actionType === "reboot") {
                systemManager.restart();
            } else if (root.actionType === "close_shell") {
                Qt.quit();
            }
        }
    }

    function startTransition(type) {
        root.actionType = type;
        root.isActive = true;
        root.opacity = 1.0;
        soundController.playConfirm();
        execTimer.restart();
    }
}
