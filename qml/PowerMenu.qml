import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent

    property bool isOpen: false
    property int selectedIndex: 0

    signal closeRequested()
    signal switchUserRequested()
    signal powerActionRequested(string actionId)

    readonly property var powerOptions: [
        { id: "rest", name: "Enter Rest Mode", desc: "Suspend power to system. Wake up instantly with controller.", icon: "qrc:/assets/icons/rest_mode.svg" },
        { id: "poweroff", name: "Turn Off System", desc: "Completely power off the system and close all running applications.", icon: "qrc:/assets/icons/power.svg" },
        { id: "reboot", name: "Restart System", desc: "Reboot the system and restart the Orbis OS desktop session.", icon: "qrc:/assets/icons/restart.svg" },
        { id: "switch_user", name: "Switch User", desc: "Log in with another user profile without logging out.", icon: "qrc:/assets/icons/profile.svg" },
        { id: "logout", name: "Log Out", desc: "Log out the current user profile and return to welcome screen.", icon: "qrc:/assets/icons/power.svg" },
        { id: "close_shell", name: "Close Orbis Shell", desc: "Exit the Orbis OS Shell interface and return to desktop session.", icon: "qrc:/assets/icons/close_app.svg" }
    ]

    visible: isOpen
    opacity: isOpen ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 180 } }

    Rectangle {
        anchors.fill: parent
        color: "#c0000a1a"

        Column {
            anchors.centerIn: parent
            spacing: 24
            width: 760

            Text {
                text: "Power"
                color: "#ffffff"
                font.pixelSize: 32
                font.weight: Font.DemiBold
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Column {
                width: parent.width
                spacing: 8

                Repeater {
                    model: root.powerOptions

                    Item {
                        required property int index
                        required property var modelData
                        width: parent.width
                        height: 68

                        readonly property bool isSelected: root.selectedIndex === index

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: isSelected ? "#16325c" : "transparent"
                            border.color: isSelected ? "#ffffff" : "#20ffffff"
                            border.width: isSelected ? 2.5 : 1

                            Row {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 20

                                Image {
                                    width: 30
                                    height: 30
                                    source: modelData.icon
                                    fillMode: Image.PreserveAspectFit
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 3

                                    Text {
                                        text: modelData.name
                                        color: "#ffffff"
                                        font.pixelSize: 18
                                        font.weight: isSelected ? Font.DemiBold : Font.Normal
                                    }

                                    Text {
                                        text: modelData.desc
                                        color: isSelected ? "#c8ddfc" : "#90a8c8"
                                        font.pixelSize: 13
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.selectedIndex = index;
                                root.triggerCurrent();
                            }
                        }
                    }
                }
            }

            // Button prompts
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 24

                Row {
                    spacing: 8
                    GamepadBadge { button: "A"; size: 20; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Select"; color: "#ffffff"; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                }

                Row {
                    spacing: 8
                    GamepadBadge { button: "B"; size: 20; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Cancel"; color: "#ffffff"; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
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
        if (selectedIndex < powerOptions.length - 1) {
            selectedIndex++;
            return true;
        }
        return false;
    }

    function triggerCurrent() {
        var opt = powerOptions[selectedIndex];
        soundController.playConfirm();
        if (opt.id === "switch_user") {
            switchUserRequested();
        } else if (opt.id === "logout") {
            soundController.playLogout();
            switchUserRequested();
        } else {
            powerActionRequested(opt.id);
        }
    }
}
