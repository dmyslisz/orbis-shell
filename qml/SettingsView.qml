import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent

    property bool isOpen: false
    property int selectedCategory: 0
    property int selectedSubItem: 0
    property bool inDetailPane: false

    signal closeRequested()

    readonly property var sysInfo: systemManager.getSystemInfo()

    readonly property var categories: [
        { id: "system_info", name: "System Information", icon: "qrc:/assets/icons/sysinfo.svg" },
        { id: "sound_screen", name: "Sound and Screen", icon: "qrc:/assets/icons/sound.svg" },
        { id: "storage", name: "Storage", icon: "qrc:/assets/icons/storage.svg" },
        { id: "network", name: "Network", icon: "qrc:/assets/icons/network.svg" },
        { id: "devices", name: "Devices & Controllers", icon: "qrc:/assets/icons/gamepad.svg" },
        { id: "power_save", name: "Power Save Settings", icon: "qrc:/assets/icons/power.svg" }
    ]

    visible: isOpen
    opacity: isOpen ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    Rectangle {
        anchors.fill: parent
        color: "#08142a"

        // Top Header
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
                    source: "qrc:/assets/icons/settings.svg"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Settings"
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

        // Main Content: Left categories column + Right detail panel
        Item {
            anchors.top: header.bottom
            anchors.topMargin: 20
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 60

            // Left categories
            ListView {
                id: catList
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: 440
                clip: true
                spacing: 6
                model: root.categories

                delegate: Item {
                    required property int index
                    required property var modelData
                    width: catList.width
                    height: 60

                    readonly property bool isSelected: root.selectedCategory === index

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: isSelected ? "#ffffff" : "transparent"

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 16

                            Image {
                                width: 26
                                height: 26
                                source: modelData.icon
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: isSelected ? 1.0 : 0.8
                            }

                            Text {
                                text: modelData.name
                                color: isSelected ? "#0a1d3d" : "#ffffff"
                                font.pixelSize: 20
                                font.weight: isSelected ? Font.Medium : Font.Normal
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedCategory = index;
                            soundController.playTick();
                        }
                    }
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: catList.right
                anchors.leftMargin: 40
                width: 1
                color: "#20ffffff"
            }

            // Right detail pane
            Item {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: catList.right
                anchors.leftMargin: 80
                anchors.right: parent.right

                // Category 0: System Information
                Column {
                    visible: root.selectedCategory === 0
                    spacing: 24
                    width: parent.width

                    Text { text: "System Information"; color: "#ffffff"; font.pixelSize: 24; font.weight: Font.DemiBold }

                    Grid {
                        columns: 2
                        rowSpacing: 18
                        columnSpacing: 24
                        width: parent.width

                        Text { text: "System OS:"; color: "#a0b8d8"; font.pixelSize: 18; width: 200 }
                        Text { text: root.sysInfo.os !== undefined ? root.sysInfo.os : "Fedora Linux 44"; color: "#ffffff"; font.pixelSize: 18 }

                        Text { text: "Kernel Version:"; color: "#a0b8d8"; font.pixelSize: 18 }
                        Text { text: root.sysInfo.kernel !== undefined ? root.sysInfo.kernel : "Linux 6.x"; color: "#ffffff"; font.pixelSize: 18 }

                        Text { text: "Processor (CPU):"; color: "#a0b8d8"; font.pixelSize: 18 }
                        Text { text: root.sysInfo.cpu !== undefined ? root.sysInfo.cpu : "x86_64"; color: "#ffffff"; font.pixelSize: 18 }

                        Text { text: "System Memory:"; color: "#a0b8d8"; font.pixelSize: 18 }
                        Text { text: (root.sysInfo.ramUsed !== undefined ? root.sysInfo.ramUsed : "4.0 GB") + " / " + (root.sysInfo.ramTotal !== undefined ? root.sysInfo.ramTotal : "16.0 GB"); color: "#ffffff"; font.pixelSize: 18 }

                        Text { text: "Desktop Shell:"; color: "#a0b8d8"; font.pixelSize: 18 }
                        Text { text: "Orbis OS Shell v1.0.0 (Wayland / X11)"; color: "#ffffff"; font.pixelSize: 18 }
                    }
                }

                // Category 1: Sound and Screen
                Column {
                    visible: root.selectedCategory === 1
                    spacing: 28
                    width: parent.width

                    Text { text: "Sound and Screen"; color: "#ffffff"; font.pixelSize: 24; font.weight: Font.DemiBold }

                    Column {
                        spacing: 12
                        width: 500

                        Row {
                            spacing: 16
                            Text { text: "Master System Volume:"; color: "#a0b8d8"; font.pixelSize: 18 }
                            Text { text: systemManager.systemVolume + "%"; color: "#ffffff"; font.pixelSize: 18; font.weight: Font.Bold }
                        }

                        Slider {
                            width: parent.width
                            from: 0
                            to: 100
                            value: systemManager.systemVolume
                            onMoved: systemManager.setSystemVolume(value)
                        }
                    }

                    Row {
                        spacing: 20
                        Button {
                            text: systemManager.isMuted ? "Unmute Master Audio" : "Mute Master Audio"
                            highlighted: systemManager.isMuted
                            onClicked: {
                                systemManager.setIsMuted(!systemManager.isMuted);
                                soundController.playConfirm();
                            }
                        }

                        Button {
                            text: soundController.bgmEnabled ? "Disable Home Screen Music" : "Enable Home Screen Music"
                            highlighted: !soundController.bgmEnabled
                            onClicked: {
                                soundController.setBgmEnabled(!soundController.bgmEnabled);
                                soundController.playConfirm();
                            }
                        }
                    }
                }

                // Category 2: Storage
                Column {
                    visible: root.selectedCategory === 2
                    spacing: 24
                    width: parent.width

                    Text { text: "Storage"; color: "#ffffff"; font.pixelSize: 24; font.weight: Font.DemiBold }

                    Text {
                        text: "System Storage (" + (root.sysInfo.storageFree !== undefined ? root.sysInfo.storageFree : "256 GB") + " free of " + (root.sysInfo.storageTotal !== undefined ? root.sysInfo.storageTotal : "512 GB") + ")"
                        color: "#a0b8d8"
                        font.pixelSize: 18
                    }

                    Rectangle {
                        width: 600
                        height: 20
                        radius: 10
                        color: "#182c4c"

                        Rectangle {
                            width: 380
                            height: parent.height
                            radius: 10
                            color: "#006FCD"
                        }
                    }

                    Row {
                        spacing: 24
                        Row {
                            spacing: 8
                            Rectangle { width: 14; height: 14; radius: 3; color: "#006FCD"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "Applications & Games"; color: "#ffffff"; font.pixelSize: 16 }
                        }
                        Row {
                            spacing: 8
                            Rectangle { width: 14; height: 14; radius: 3; color: "#182c4c"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "Free Space"; color: "#a0b8d8"; font.pixelSize: 16 }
                        }
                    }
                }

                // Category 3: Network
                Column {
                    visible: root.selectedCategory === 3
                    spacing: 24
                    width: parent.width

                    Text { text: "Network"; color: "#ffffff"; font.pixelSize: 24; font.weight: Font.DemiBold }

                    Grid {
                        columns: 2
                        rowSpacing: 18
                        columnSpacing: 24
                        width: parent.width

                        Text { text: "Status:"; color: "#a0b8d8"; font.pixelSize: 18; width: 180 }
                        Text { text: systemManager.isOnline ? "Connected to the Internet" : "Disconnected"; color: systemManager.isOnline ? "#4caf50" : "#ef5350"; font.pixelSize: 18; font.weight: Font.Medium }

                        Text { text: "Connection Method:"; color: "#a0b8d8"; font.pixelSize: 18 }
                        Text { text: systemManager.networkType; color: "#ffffff"; font.pixelSize: 18 }

                        Text { text: "PlayStation Network:"; color: "#a0b8d8"; font.pixelSize: 18 }
                        Text { text: "Signed In (Local Orbis Emulation)"; color: "#ffffff"; font.pixelSize: 18 }
                    }
                }

                // Category 4: Devices & Controllers
                Column {
                    visible: root.selectedCategory === 4
                    spacing: 24
                    width: parent.width

                    Text { text: "Controllers & Input Devices"; color: "#ffffff"; font.pixelSize: 24; font.weight: Font.DemiBold }

                    Row {
                        spacing: 20
                        Image {
                            width: 64
                            height: 64
                            source: "qrc:/assets/icons/ControllerWhite.png"
                            fillMode: Image.PreserveAspectFit
                        }
                        Column {
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: gamepadManager.gamepadConnected ? gamepadManager.gamepadName : "Keyboard & Mouse (Standard Controller)"
                                color: "#ffffff"
                                font.pixelSize: 20
                                font.weight: Font.Medium
                            }
                            Text {
                                text: gamepadManager.gamepadConnected ? "Connected via SDL3 Gamepad" : "Connected via Linux evdev"
                                color: "#a0c0e8"
                                font.pixelSize: 16
                            }
                        }
                    }
                }

                // Category 5: Power Save
                Column {
                    visible: root.selectedCategory === 5
                    spacing: 24
                    width: parent.width

                    Text { text: "Power Save Settings"; color: "#ffffff"; font.pixelSize: 24; font.weight: Font.DemiBold }

                    Text {
                        text: "Configure sleep intervals and rest mode behavior."
                        color: "#a0c0e8"
                        font.pixelSize: 16
                    }

                    Button {
                        text: "Enter Rest Mode Now"
                        onClicked: {
                            systemManager.enterRestMode();
                            soundController.playConfirm();
                        }
                    }
                }
            }
        }
    }

    function selectPrevious() {
        if (selectedCategory > 0) {
            selectedCategory--;
            return true;
        }
        return false;
    }

    function selectNext() {
        if (selectedCategory < categories.length - 1) {
            selectedCategory++;
            return true;
        }
        return false;
    }
}
