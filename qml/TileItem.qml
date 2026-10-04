import QtQuick
import QtQuick.Controls

Item {
    id: root

    property var appData: null
    property int itemIndex: 0
    property int focusedIndex: 0
    property bool isRowFocused: true

    readonly property bool isCurrent: itemIndex === focusedIndex
    readonly property bool isFocused: isCurrent && isRowFocused

    // Exact PS4 dimensions (1080p base)
    readonly property real baseSize: 204
    readonly property real focusedWidth: 320
    readonly property real focusedHeight: 390
    readonly property real extraShift: (focusedWidth - baseSize) + 36

    // Shift neighbor tiles to the right only when the row is actively focused
    readonly property real targetShiftX: {
        if (root.isRowFocused && itemIndex > focusedIndex) {
            return root.extraShift;
        } else {
            return 0.0;
        }
    }

    property real currentShiftX: targetShiftX
    Behavior on currentShiftX {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    x: (itemIndex * (baseSize + 18)) + currentShiftX
    y: isFocused ? -20 : 0
    z: isCurrent ? 20 : (100 - Math.abs(itemIndex - focusedIndex))

    width: isFocused ? focusedWidth : baseSize
    height: isFocused ? focusedHeight : baseSize

    Behavior on y {
        NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
    }
    Behavior on width {
        NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
    }
    Behavior on height {
        NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
    }

    // Tile Box Container
    Rectangle {
        id: tileBox
        anchors.fill: parent
        radius: 2
        clip: true
        color: (root.appData && root.appData.gradientEnd) ? root.appData.gradientEnd : "#0a1d3d"

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: (root.appData && root.appData.gradientStart) ? root.appData.gradientStart : "#1a3d7c"
            }
            GradientStop {
                position: 1.0
                color: (root.appData && root.appData.gradientEnd) ? root.appData.gradientEnd : "#0a1d3d"
            }
        }

        // Top artwork square
        Item {
            id: artArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.isFocused ? (root.focusedWidth) : root.baseSize

            Image {
                anchors.fill: parent
                source: (root.appData && root.appData.icon) ? root.appData.icon : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                mipmap: true
            }

            // Subtitle badge if any (e.g. "DIGITAL", "STEAM", "COMMUNITY")
            Rectangle {
                visible: root.isFocused && root.appData && root.appData.context && root.appData.context.badge
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                width: badgeText.implicitWidth + 14
                height: 22
                radius: 3
                color: "#c0001030"
                border.color: "#60ffffff"
                border.width: 1

                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: (root.appData && root.appData.context && root.appData.context.badge) ? root.appData.context.badge : ""
                    color: "#ffffff"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }
            }
        }

        // Bottom drawer section (visible only when focused)
        // Only on "What's New": down arrow
        // On all other tiles: "Start" written
        Rectangle {
            id: bottomDrawer
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 64
            color: "#003b8e"
            visible: root.isFocused
            opacity: root.isFocused ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            // What's New: Down Arrow
            Row {
                anchors.centerIn: parent
                spacing: 8
                visible: root.appData && root.appData.id === "whats_new"

                Image {
                    width: 18
                    height: 18
                    source: "qrc:/assets/icons/down_arrow.svg"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Overview"
                    color: "#b0d0ff"
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // All other tiles: "Start" written
            Text {
                anchors.centerIn: parent
                visible: !root.appData || root.appData.id !== "whats_new"
                text: (processLauncher.isAppRunning && processLauncher.currentAppName === (root.appData ? root.appData.name : "")) ? "Resume" : "Start"
                color: "#ffffff"
                font.pixelSize: 18
                font.weight: Font.DemiBold
            }
        }

        // 3.5px Solid Crisp White Border (signature PS4 focus frame)
        Rectangle {
            anchors.fill: parent
            radius: 2
            color: "transparent"
            border.color: "#ffffff"
            border.width: 3.5
            visible: root.isFocused
        }
    }

    // Game / App Title displayed directly to the right of the focused tile (PS4 style)
    Item {
        anchors.left: tileBox.right
        anchors.leftMargin: 24
        anchors.bottom: tileBox.bottom
        anchors.bottomMargin: 14
        width: 600
        height: 52
        visible: root.isFocused
        opacity: root.isFocused ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
        }

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: (root.appData && root.appData.name) ? root.appData.name : ""
            color: "#ffffff"
            font.pixelSize: 34
            font.weight: Font.Normal
            elide: Text.ElideRight
            width: 580
        }
    }
}
