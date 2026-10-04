import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent

    property bool isOpen: false
    property int selectedIndex: 0

    signal closeRequested()

    readonly property var notificationsList: [
        { title: "Controller 1 Connected", time: "Just now", icon: "qrc:/assets/icons/gamepad.svg", desc: "DualShock / Gamepad active with low latency" },
        { title: "Steam Library Indexed", time: "2m ago", icon: "qrc:/assets/icons/steam.svg", desc: "Ready to launch games via Proton" },
        { title: "Trophy Unlocked: Silky Smooth 60 FPS", time: "5m ago", icon: "qrc:/assets/icons/trophy_gold.svg", desc: "Run the launcher on native Wayland on Fedora Linux" },
        { title: "Orbis OS Shell Ready", time: "10m ago", icon: "qrc:/assets/icons/settings.svg", desc: "Desktop Environment session active" }
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
            anchors.margins: 60

            Row {
                spacing: 20
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    width: 36
                    height: 36
                    source: "qrc:/assets/icons/notifications.svg"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Notifications"
                    color: "#ffffff"
                    font.pixelSize: 32
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Back hint
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Image {
                    width: 22
                    height: 22
                    source: "qrc:/assets/icons/buttons/PS4_Circle.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Back"
                    color: "#ffffff"
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
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
            anchors.topMargin: 30
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 60
            spacing: 10
            model: root.notificationsList

            delegate: Item {
                required property int index
                required property var modelData
                width: notifListView.width
                height: 74

                readonly property bool isSelected: root.selectedIndex === index

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: isSelected ? "#ffffff" : "#0d1e38"
                    border.color: isSelected ? "#ffffff" : "#18ffffff"
                    border.width: isSelected ? 2 : 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 20

                        Image {
                            width: 34
                            height: 34
                            source: modelData.icon
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
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
                                color: isSelected ? "#2a4d7d" : "#90a8c8"
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
