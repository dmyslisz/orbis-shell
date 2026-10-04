import QtQuick

Item {
    id: root
    anchors.fill: parent
    z: 1000
    visible: opacity > 0.001
    opacity: 0.0

    property var appData: null
    property bool isLaunching: false

    signal launchCompleted()

    // Smooth overall fade
    Behavior on opacity {
        NumberAnimation { duration: 240; easing.type: Easing.OutQuad }
    }

    // 1. Deep solid pitch black background (PS4 splash backdrop)
    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    // 2. Icon zoom & dissolve container
    Item {
        id: iconZoomContainer
        anchors.centerIn: parent
        width: 320
        height: 320

        scale: root.isLaunching ? 1.45 : 0.95
        opacity: root.isLaunching ? 0.0 : 1.0

        Behavior on scale {
            NumberAnimation { duration: 520; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 420; easing.type: Easing.InQuad }
        }

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: "transparent"
            clip: true

            Image {
                anchors.fill: parent
                source: (root.appData && root.appData.icon) ? root.appData.icon : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                mipmap: true
            }
        }
    }

    // 3. Centered Title / Logo reveal & scale (Photo/Video at 13:31)
    Item {
        id: titleContainer
        anchors.centerIn: parent
        width: parent.width - 160
        height: 240

        scale: root.isLaunching ? 1.0 : 0.82
        opacity: root.isLaunching ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 380; easing.type: Easing.OutQuad }
        }

        Column {
            anchors.centerIn: parent
            spacing: 12

            Text {
                text: root.appData ? root.appData.name : ""
                color: "#ffffff"
                font.pixelSize: 48
                font.weight: Font.Bold
                font.letterSpacing: 2
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                elide: Text.ElideRight
                maximumLineCount: 2
                width: titleContainer.width
            }

            Text {
                visible: root.appData && (root.appData.category || (root.appData.context && root.appData.context.badge))
                text: (root.appData && root.appData.context && root.appData.context.badge) ? root.appData.context.badge : (root.appData ? root.appData.category : "")
                color: "#90a4c4"
                font.pixelSize: 16
                font.weight: Font.Medium
                font.letterSpacing: 3
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.8
            }
        }
    }

    // Splash hold timer (holds splash on pitch black screen like PS4)
    Timer {
        id: holdTimer
        interval: 2200
        onTriggered: {
            root.opacity = 0.0;
            fadeTimer.restart();
        }
    }

    Timer {
        id: fadeTimer
        interval: 260
        onTriggered: {
            root.isLaunching = false;
            root.launchCompleted();
        }
    }

    function startLaunch(data) {
        root.appData = data;
        root.isLaunching = false;
        root.opacity = 1.0;
        animStartTimer.restart();
    }

    Timer {
        id: animStartTimer
        interval: 20
        onTriggered: {
            root.isLaunching = true;
            holdTimer.restart();
        }
    }
}
