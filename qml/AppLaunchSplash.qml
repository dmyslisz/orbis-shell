import QtQuick

Item {
    id: root
    anchors.fill: parent
    z: 250
    visible: opacity > 0.001
    opacity: 0.0

    property var appData: null
    property bool isLaunching: false

    signal launchCompleted()

    Behavior on opacity {
        NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
    }

    // Deep sapphire background with radial vignette
    Rectangle {
        anchors.fill: parent
        color: "#030a18"

        // Ambient radial glow behind the icon
        Rectangle {
            anchors.centerIn: parent
            width: 700
            height: 700
            radius: 350
            color: (root.appData && root.appData.gradientStart) ? root.appData.gradientStart : "#0f326c"
            opacity: 0.28
        }
    }

    // Zoom-in / scale container for the icon and branding
    Item {
        id: centerContent
        anchors.centerIn: parent
        width: 600
        height: 480
        scale: root.isLaunching ? 1.0 : 0.7
        opacity: root.isLaunching ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 320; easing.type: Easing.OutQuad }
        }

        Column {
            anchors.centerIn: parent
            spacing: 32

            // Glowing Icon Box
            Item {
                width: 220
                height: 220
                anchors.horizontalCenter: parent.horizontalCenter

                // Soft outer glow ring
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 24
                    height: parent.height + 24
                    radius: 16
                    color: "transparent"
                    border.color: "#80d0ff"
                    border.width: 3
                    opacity: 0.6

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: root.isLaunching
                        NumberAnimation { to: 0.9; duration: 750; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.35; duration: 750; easing.type: Easing.InOutSine }
                    }
                }

                // Main Icon card
                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "#0a1d3d"
                    clip: true
                    border.color: "#ffffff"
                    border.width: 2

                    Image {
                        anchors.fill: parent
                        source: (root.appData && root.appData.icon) ? root.appData.icon : ""
                        fillMode: Image.PreserveAspectCrop
                        mipmap: true
                    }
                }
            }

            // App Name & Status
            Column {
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: root.appData ? root.appData.name : ""
                    color: "#ffffff"
                    font.pixelSize: 32
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Starting..."
                    color: "#a0c8f8"
                    font.pixelSize: 18
                    font.weight: Font.Normal
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // Authentic PS4 Loading Shimmer Bar
            Rectangle {
                width: 320
                height: 4
                radius: 2
                color: "#204070"
                anchors.horizontalCenter: parent.horizontalCenter
                clip: true

                Rectangle {
                    id: shimmer
                    width: 90
                    height: parent.height
                    radius: 2
                    color: "#ffffff"

                    PropertyAnimation on x {
                        from: -100
                        to: 330
                        duration: 1100
                        loops: Animation.Infinite
                        running: root.isLaunching
                    }
                }
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 1800
        onTriggered: {
            root.isLaunching = false;
            root.opacity = 0.0;
            fadeTimer.restart();
        }
    }

    Timer {
        id: fadeTimer
        interval: 300
        onTriggered: root.launchCompleted()
    }

    function startLaunch(data) {
        root.appData = data;
        root.opacity = 1.0;
        root.isLaunching = true;
        hideTimer.restart();
    }
}
