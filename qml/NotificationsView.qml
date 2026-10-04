import QtQuick

Item {
    id: root
    anchors.fill: parent

    property bool isOpen: false
    property int selectedIndex: 0

    signal closeRequested()

    readonly property var notificationsList: [
        { title: "Controller Connected", time: "Just now", icon: "qrc:/assets/icons/gamepad.svg", desc: "Gamepad detected with low latency polling via SDL3" },
        { title: "Steam Library Synchronized", time: "2m ago", icon: "qrc:/assets/icons/steam.svg", desc: "Installed Steam games discovered and ready" },
        { title: "PipeWire Audio Active", time: "5m ago", icon: "qrc:/assets/icons/sound.svg", desc: "Hardware audio sink initialized" },
        { title: "Orbis OS Shell Initialized", time: "10m ago", icon: "qrc:/assets/icons/sysinfo.svg", desc: "Fedora Linux desktop environment session ready" }
    ]

    visible: isOpen
    opacity: isOpen ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 180 } }

    Rectangle {
        anchors.fill: parent
        color: "#08142a"

        Item {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 100
            anchors.margins: 70

            Row {
                spacing: 16
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    width: 32
                    height: 32
                    source: "qrc:/assets/icons/notifications.svg"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Notifications"
                    color: "#ffffff"
                    font.pixelSize: 30
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Action hints
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 24

                Row {
                    spacing: 8
                    Image { width: 20; height: 20; source: "qrc:/assets/icons/buttons/PS4_Cross.png"; fillMode: Image.PreserveAspectFit; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "View"; color: "#ffffff"; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                }

                Row {
                    spacing: 8
                    Image { width: 20; height: 20; source: "qrc:/assets/icons/buttons/PS4_Circle.png"; fillMode: Image.PreserveAspectFit; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Back"; color: "#ffffff"; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                }
            }
        }

        Rectangle {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#20ffffff"
        }

        ListView {
            id: notifListView
            anchors.top: header.bottom
            anchors.topMargin: 24
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 70
            spacing: 10
            model: root.notificationsList

            delegate: Item {
                required property int index
                required property var modelData
                width: notifListView.width
                height: 72

                readonly property bool isSelected: root.selectedIndex === index

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: isSelected ? "#ffffff" : "#0e1e3a"
                    border.color: isSelected ? "#ffffff" : "#20ffffff"
                    border.width: isSelected ? 2 : 1

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 20

                        Image {
                            width: 32
                            height: 32
                            source: modelData.icon
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: isSelected ? 0.95 : 0.75
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Text {
                                text: modelData.title
                                color: isSelected ? "#0a1d3d" : "#ffffff"
                                font.pixelSize: 18
                                font.weight: isSelected ? Font.DemiBold : Font.Normal
                            }

                            Text {
                                text: modelData.desc
                                color: isSelected ? "#2a4d7d" : "#80a8d8"
                                font.pixelSize: 14
                            }
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.time
                            color: isSelected ? "#0a1d3d" : "#6080a0"
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
    }

    function selectPrevious() {
        if (selectedIndex > 0) {
            selectedIndex--;
            return true;
        }
        return false;
    }

    function selectNext() {
        if (selectedIndex < notificationsList.length - 1) {
            selectedIndex++;
            return true;
        }
        return false;
    }
}
