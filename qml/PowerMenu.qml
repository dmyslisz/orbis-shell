import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent

    property bool isOpen: false
    property int selectedIndex: 0

    signal closeRequested()
    signal switchUserRequested()

    readonly property var powerOptions: [
        { id: "rest", name: "Enter Rest Mode", desc: "Suspend power to system. Wake up instantly with controller.", icon: "qrc:/assets/icons/rest_mode.svg" },
        { id: "poweroff", name: "Turn Off PS4", desc: "Completely power off the system and close all running applications.", icon: "qrc:/assets/icons/power.svg" },
        { id: "reboot", name: "Restart PS4", desc: "Reboot the system and restart the Orbis OS desktop session.", icon: "qrc:/assets/icons/restart.svg" },
        { id: "switch_user", name: "Switch User", desc: "Log in with another user profile without logging out.", icon: "qrc:/assets/icons/profile.svg" },
        { id: "logout", name: "Log Out of PS4", desc: "Log out the current user profile and return to welcome screen.", icon: "qrc:/assets/icons/power.svg" }
    ]

    visible: isOpen
    opacity: isOpen ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 180 } }

    Rectangle {
        anchors.fill: parent
        color: "#c0000a1a"

        Column {
            anchors.centerIn: parent
            spacing: 32
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
                spacing: 10

                Repeater {
                    model: root.powerOptions

                    Item {
                        required property int index
                        required property var modelData
                        width: parent.width
                        height: 72

                        readonly property bool isSelected: root.selectedIndex === index

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: isSelected ? "#ffffff" : "#14243e"
                            border.color: isSelected ? "#ffffff" : "#20ffffff"
                            border.width: isSelected ? 2 : 1

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
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4

                                    Text {
                                        text: modelData.name
                                        color: isSelected ? "#0a1d3d" : "#ffffff"
                                        font.pixelSize: 18
                                        font.weight: isSelected ? Font.DemiBold : Font.Normal
                                    }

                                    Text {
                                        text: modelData.desc
                                        color: isSelected ? "#2a4d7d" : "#90a8c8"
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
                    Image { width: 20; height: 20; source: "qrc:/assets/icons/buttons/PS4_Cross.png"; fillMode: Image.PreserveAspectFit; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Select"; color: "#ffffff"; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                }

                Row {
                    spacing: 8
                    Image { width: 20; height: 20; source: "qrc:/assets/icons/buttons/PS4_Circle.png"; fillMode: Image.PreserveAspectFit; anchors.verticalCenter: parent.verticalCenter }
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
        if (opt.id === "rest") {
            systemManager.enterRestMode();
        } else if (opt.id === "poweroff") {
            systemManager.turnOff();
        } else if (opt.id === "reboot") {
            systemManager.restart();
        } else if (opt.id === "switch_user") {
            switchUserRequested();
        } else if (opt.id === "logout") {
            soundController.playLogout();
            switchUserRequested();
        }
    }
}
