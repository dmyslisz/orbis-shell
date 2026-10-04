import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: parent.width
    height: 1080

    property var currentAppData: null
    property bool isOpen: false
    property int selectedDeckItem: 0

    signal launchRequested()
    signal closeRequested()

    y: isOpen ? 0 : 1080
    visible: y < 1079
    opacity: isOpen ? 1.0 : 0.0

    Behavior on y {
        NumberAnimation { duration: 240; easing.type: Easing.OutQuad }
    }
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    Item {
        anchors.fill: parent
        anchors.margins: 80
        anchors.topMargin: 160

        Column {
            spacing: 32
            width: parent.width

            // Header Row: App icon, Title, Playtime
            Row {
                spacing: 24
                anchors.left: parent.left

                Rectangle {
                    width: 72
                    height: 72
                    radius: 6
                    color: "#0a1d3d"
                    border.color: "#ffffff"
                    border.width: 2
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: (root.currentAppData && root.currentAppData.icon) ? root.currentAppData.icon : ""
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Text {
                        text: (root.currentAppData && root.currentAppData.name) ? root.currentAppData.name : ""
                        color: "#ffffff"
                        font.pixelSize: 32
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: (root.currentAppData && root.currentAppData.context && root.currentAppData.context.playtime) ? root.currentAppData.context.playtime : "Installed"
                        color: "#a0c0e8"
                        font.pixelSize: 16
                    }
                }
            }

            // Primary Big Action Card ("Start" / "Resume")
            Row {
                spacing: 24

                Rectangle {
                    width: 220
                    height: 64
                    radius: 6
                    color: root.selectedDeckItem === 0 ? "#16325c" : "#c0001844"
                    border.color: "#ffffff"
                    border.width: root.selectedDeckItem === 0 ? 3 : 1.5

                    scale: root.selectedDeckItem === 0 ? 1.05 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 12

                        GamepadBadge {
                            button: "A"
                            size: 22
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: (processLauncher.isAppRunning && processLauncher.currentAppName === (root.currentAppData ? root.currentAppData.name : "")) ? "Resume" : "Start"
                            color: "#ffffff"
                            font.pixelSize: 22
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Options hint
                Rectangle {
                    width: 160
                    height: 64
                    radius: 6
                    color: "#80001030"
                    border.color: "#30ffffff"
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        GamepadBadge {
                            button: "OPTIONS"
                            size: 20
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Options"
                            color: "#c0d4f0"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // Cards Row: Overview, Patch Notes / Activities, Trophies
            Row {
                spacing: 28
                width: parent.width

                // Card 1: Overview
                Rectangle {
                    width: 480
                    height: 320
                    radius: 8
                    color: "#b0081c3c"
                    border.color: root.selectedDeckItem === 1 ? "#ffffff" : "#20ffffff"
                    border.width: root.selectedDeckItem === 1 ? 2.5 : 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 28
                        spacing: 16

                        Text {
                            text: (root.currentAppData && root.currentAppData.context && root.currentAppData.context.headline) ? root.currentAppData.context.headline : "Overview"
                            color: "#ffffff"
                            font.pixelSize: 20
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: parent.width
                            text: (root.currentAppData && root.currentAppData.context && root.currentAppData.context.description) ? root.currentAppData.context.description : "No description available for this application."
                            color: "#b0c8e8"
                            font.pixelSize: 15
                            wrapMode: Text.WordWrap
                            lineHeight: 1.3
                        }
                    }
                }

                // Card 2: Recent Activities & Version
                Rectangle {
                    width: 480
                    height: 320
                    radius: 8
                    color: "#b0081c3c"
                    border.color: root.selectedDeckItem === 2 ? "#ffffff" : "#20ffffff"
                    border.width: root.selectedDeckItem === 2 ? 2.5 : 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 28
                        spacing: 18

                        Text {
                            text: "Recent Activities & Notes"
                            color: "#ffffff"
                            font.pixelSize: 20
                            font.weight: Font.DemiBold
                        }

                        Row {
                            spacing: 12
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: "#006FCD"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: (root.currentAppData && root.currentAppData.context && root.currentAppData.context.patchNotes) ? root.currentAppData.context.patchNotes : "Latest Version"
                                color: "#ffffff"
                                font.pixelSize: 16
                            }
                        }

                        Text {
                            width: parent.width
                            text: "Optimized for Fedora 44 Linux. Full controller vibration, analog triggers, and instant resume support enabled."
                            color: "#a0c0e8"
                            font.pixelSize: 14
                            wrapMode: Text.WordWrap
                            lineHeight: 1.3
                        }
                    }
                }

                // Card 3: Technical Details
                Rectangle {
                    width: 480
                    height: 320
                    radius: 8
                    color: "#b0081c3c"
                    border.color: root.selectedDeckItem === 3 ? "#ffffff" : "#20ffffff"
                    border.width: root.selectedDeckItem === 3 ? 2.5 : 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 28
                        spacing: 20

                        Text {
                            text: "Technical Details"
                            color: "#ffffff"
                            font.pixelSize: 20
                            font.weight: Font.DemiBold
                        }

                        Row {
                            spacing: 16
                            Image {
                                width: 36
                                height: 36
                                source: "qrc:/assets/icons/sysinfo.svg"
                                fillMode: Image.PreserveAspectFit
                            }
                            Column {
                                spacing: 4
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: "Session: Native Wayland"
                                    color: "#ffffff"
                                    font.pixelSize: 16
                                    font.weight: Font.Medium
                                }
                                Text {
                                    text: "Gamepad: SDL3 Gamepad Subsystem"
                                    color: "#a0c0e8"
                                    font.pixelSize: 14
                                }
                            }
                        }

                        Text {
                            text: "Execution Mode: Direct Desktop Session\nAudio Output: PipeWire Sink\nDisplay Mode: 1080p 60 FPS"
                            color: "#80a8d8"
                            font.pixelSize: 14
                            lineHeight: 1.4
                        }
                    }
                }
            }
        }
    }

    function selectPrevious() {
        if (selectedDeckItem > 0) {
            selectedDeckItem--;
            return true;
        }
        return false;
    }

    function selectNext() {
        if (selectedDeckItem < 3) {
            selectedDeckItem++;
            return true;
        }
        return false;
    }

    function triggerCurrent() {
        if (selectedDeckItem === 0) {
            launchRequested();
        }
    }
}
