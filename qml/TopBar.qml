import QtQuick

Item {
    id: root
    width: parent.width
    height: 1080

    property bool isFocused: false
    property int selectedIndex: 0
    property string userName: "User 1"
    property string userAvatar: "qrc:/assets/avatars/avatar_luchador.svg"

    signal iconSelected(int index, string name)

    readonly property var icons: [
        { id: "notifications", name: "Notifications", icon: "qrc:/assets/icons/notifications.svg" },
        { id: "settings", name: "Settings", icon: "qrc:/assets/icons/settings.svg" },
        { id: "power", name: "Power", icon: "qrc:/assets/icons/power.svg" }
    ]

    // ==========================================
    // 1. TOP-RIGHT PERMANENT CLOCK, BATTERY & WI-FI
    // ==========================================
    Row {
        anchors.top: parent.top
        anchors.topMargin: 50
        anchors.right: parent.right
        anchors.rightMargin: 80
        spacing: 16
        height: 32
        z: 10

        // Network icon
        Image {
            width: 20
            height: 20
            source: "qrc:/assets/icons/WiFiHigh.png"
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter
            opacity: systemManager.isOnline ? 0.95 : 0.4
        }

        // Battery indicator
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            visible: systemManager.hasBattery

            Rectangle {
                width: 26
                height: 14
                radius: 2
                color: "transparent"
                border.color: "#ffffff"
                border.width: 1.5
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    x: 2
                    y: 2
                    width: Math.max(3, (parent.width - 4) * (systemManager.batteryPercent / 100.0))
                    height: parent.height - 4
                    color: systemManager.isCharging ? "#66bb6a" : (systemManager.batteryPercent < 20 ? "#ef5350" : "#ffffff")
                }
            }

            Rectangle {
                width: 2
                height: 6
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Clock Text
        Text {
            id: clockText
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
            font.pixelSize: 22
            font.weight: Font.Normal
            text: Qt.formatTime(new Date(), "h:mm AP")
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockText.text = Qt.formatTime(new Date(), "h:mm AP")
        }
    }

    // ==========================================
    // 2. MAIN FUNCTION BAR (Slides down when focused like PS4)
    // ==========================================
    Item {
        id: barContainer
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.right: parent.right
        anchors.rightMargin: 80
        height: 180

        // In PS4: Top bar sits at y: 48 when unfocused; slides down to y: 210 when focused!
        y: root.isFocused ? 200 : 48

        Behavior on y {
            NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
        }

        // Icons Row
        Row {
            id: iconsRow
            anchors.top: parent.top
            anchors.left: parent.left
            spacing: root.isFocused ? 32 : 24

            Behavior on spacing {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }

            Repeater {
                model: root.icons

                Item {
                    required property int index
                    required property var modelData
                    width: root.isFocused ? 58 : 40
                    height: root.isFocused ? 58 : 40

                    readonly property bool isSelected: root.isFocused && root.selectedIndex === index

                    Behavior on width { NumberAnimation { duration: 180 } }
                    Behavior on height { NumberAnimation { duration: 180 } }

                    Rectangle {
                        anchors.centerIn: parent
                        width: isSelected ? 62 : parent.width
                        height: isSelected ? 62 : parent.height
                        radius: 8
                        color: isSelected ? "#3060a0" : "transparent"
                        border.color: isSelected ? "#ffffff" : "transparent"
                        border.width: isSelected ? 2.5 : 0

                        Behavior on width { NumberAnimation { duration: 160 } }
                        Behavior on height { NumberAnimation { duration: 160 } }

                        Image {
                            anchors.centerIn: parent
                            width: isSelected ? 34 : (root.isFocused ? 28 : 22)
                            height: isSelected ? 34 : (root.isFocused ? 28 : 22)
                            source: modelData.icon
                            fillMode: Image.PreserveAspectFit
                            opacity: isSelected ? 1.0 : (root.isFocused ? 0.8 : 0.65)

                            Behavior on width { NumberAnimation { duration: 160 } }
                            Behavior on height { NumberAnimation { duration: 160 } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedIndex = index;
                            iconSelected(index, modelData.name);
                        }
                    }
                }
            }
        }

        // Focused Item Label (displayed directly under the active icon)
        Text {
            anchors.top: iconsRow.bottom
            anchors.topMargin: 16
            anchors.left: parent.left
            x: root.selectedIndex * (58 + 32)
            text: root.icons[root.selectedIndex].name
            color: "#ffffff"
            font.pixelSize: 22
            font.weight: Font.Medium
            opacity: root.isFocused ? 1.0 : 0.0

            Behavior on x {
                NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
            }
            Behavior on opacity {
                NumberAnimation { duration: 160 }
            }
        }
    }

    function selectNext() {
        if (selectedIndex < icons.length - 1) {
            selectedIndex++;
            return true;
        }
        return false;
    }

    function selectPrevious() {
        if (selectedIndex > 0) {
            selectedIndex--;
            return true;
        }
        return false;
    }

    function currentItem() {
        return icons[selectedIndex];
    }
}
