import QtQuick

Item {
    id: root
    anchors.fill: parent

    property bool isOpen: false
    property int selectedIndex: 0

    signal closeRequested()

    readonly property var notificationsList: [
        { title: "Controller Connected", time: "Just now", icon: "qrc:/assets/icons/gamepad.svg", desc: "Gamepad detected with low-latency polling via SDL3" },
        { title: "Installed Apps Scanned", time: "2m ago", icon: "qrc:/assets/icons/library.svg", desc: "Desktop applications catalog synchronized" },
        { title: "Audio System Active", time: "5m ago", icon: "qrc:/assets/icons/sound.svg", desc: "Native Linux audio sink initialized" },
        { title: "Orbis OS Shell Initialized", time: "10m ago", icon: "qrc:/assets/icons/launcher_logo.svg", desc: "Fedora Linux desktop environment session ready" }
    ]

    visible: isOpen
    opacity: isOpen ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 180 } }

    Rectangle {
        anchors.fill: parent
        color: "#08142a"

        // Top Header: "Notifications" (Photo 3)
        Item {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 110
            anchors.leftMargin: 90
            anchors.rightMargin: 90

            Text {
                text: "Notifications"
                color: "#ffffff"
                font.pixelSize: 36
                font.weight: Font.Normal
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
            }
        }

        // Divider line beneath header
        Rectangle {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 90
            anchors.rightMargin: 90
            height: 1
            color: "#20ffffff"
        }

        // Main List of Notifications (Photo 3)
        ListView {
            id: notifListView
            anchors.top: header.bottom
            anchors.topMargin: 20
            anchors.bottom: bottomBar.top
            anchors.bottomMargin: 20
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 90
            anchors.rightMargin: 120
            spacing: 8
            clip: true
            model: root.notificationsList

            delegate: Item {
                required property int index
                required property var modelData
                width: notifListView.width
                height: 78

                readonly property bool isSelected: root.selectedIndex === index

                // Notification Slot (Photo 3 style: Crisp White Outline when selected, dark background)
                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: isSelected ? "#16325c" : "transparent"
                    border.color: isSelected ? "#ffffff" : "transparent"
                    border.width: isSelected ? 2.5 : 0

                    // Subtle bottom divider line when unselected
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: "#18ffffff"
                        visible: !isSelected
                    }

                    Item {
                        anchors.fill: parent
                        anchors.margins: 16

                        // Left monochrome white icon
                        Image {
                            id: notifIcon
                            width: 32
                            height: 32
                            source: modelData.icon
                            fillMode: Image.PreserveAspectFit
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: isSelected ? 1.0 : 0.8
                        }

                        // Middle title and description
                        Column {
                            anchors.left: notifIcon.right
                            anchors.leftMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Text {
                                text: modelData.title
                                color: "#ffffff"
                                font.pixelSize: 18
                                font.weight: isSelected ? Font.Medium : Font.Normal
                            }

                            Text {
                                text: modelData.desc
                                color: isSelected ? "#b8d4f8" : "#80a8d8"
                                font.pixelSize: 14
                            }
                        }

                        // Right timestamp
                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.time
                            color: isSelected ? "#ffffff" : "#6888b0"
                            font.pixelSize: 14
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedIndex = index;
                            soundController.playConfirm();
                        }
                    }
                }
            }
        }

        // Scrollbar Track & Thumb (Photo 3)
        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 96
            anchors.top: header.bottom
            anchors.topMargin: 24
            anchors.bottom: bottomBar.top
            anchors.bottomMargin: 24
            width: 3
            color: "#18ffffff"

            Rectangle {
                width: 3
                height: 48
                color: "#80c0ff"
                y: root.notificationsList.length > 1
                   ? (parent.height - height) * (root.selectedIndex / (root.notificationsList.length - 1))
                   : 0
                Behavior on y { NumberAnimation { duration: 100 } }
            }
        }

        // Bottom Action Prompts Bar (Photo 3)
        Row {
            id: bottomBar
            anchors.left: parent.left
            anchors.leftMargin: 90
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 36
            spacing: 36

            Row {
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter
                GamepadBadge { button: "A"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "View"; color: "#ffffff"; font.pixelSize: 17; anchors.verticalCenter: parent.verticalCenter }
            }

            Row {
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter
                GamepadBadge { button: "B"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Back"; color: "#ffffff"; font.pixelSize: 17; anchors.verticalCenter: parent.verticalCenter }
            }

            Row {
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter
                GamepadBadge { button: "OPTIONS"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Options Menu"; color: "#ffffff"; font.pixelSize: 17; anchors.verticalCenter: parent.verticalCenter }
            }
        }
    }

    function selectPrevious() {
        if (selectedIndex > 0) {
            selectedIndex--;
            soundController.playTick();
            return true;
        }
        return false;
    }

    function selectNext() {
        if (selectedIndex < notificationsList.length - 1) {
            selectedIndex++;
            soundController.playTick();
            return true;
        }
        return false;
    }
}
