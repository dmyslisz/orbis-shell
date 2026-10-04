import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent

    property bool isOpen: false

    // 0 = Left Categories list, 1 = Right Detail pane
    property int activePane: 0
    property int selectedCategory: 0
    property int rightSelectedIndex: 0

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

            // Action Hints
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 24

                Row {
                    spacing: 8
                    Image { width: 20; height: 20; source: "qrc:/assets/icons/buttons/PS4_Cross.png"; fillMode: Image.PreserveAspectFit; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Select"; color: "#ffffff"; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
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

        // Main Content Area: Left Categories + Right Action Pane
        Item {
            anchors.top: header.bottom
            anchors.topMargin: 20
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 60

            // Left Categories Column
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

                    readonly property bool isCurrent: root.selectedCategory === index
                    readonly property bool isFocused: isCurrent && root.activePane === 0

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: isFocused ? "#ffffff" : (isCurrent ? "#204272" : "transparent")
                        border.color: isFocused ? "#ffffff" : "transparent"
                        border.width: isFocused ? 2 : 0

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
                                opacity: isFocused ? 1.0 : 0.85
                            }

                            Text {
                                text: modelData.name
                                color: isFocused ? "#0a1d3d" : "#ffffff"
                                font.pixelSize: 20
                                font.weight: isCurrent ? Font.Medium : Font.Normal
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedCategory = index;
                            root.activePane = 0;
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

            // Right Detail & Action Pane
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
                    spacing: 24
                    width: parent.width

                    Text { text: "Sound and Screen"; color: "#ffffff"; font.pixelSize: 24; font.weight: Font.DemiBold }

                    // Sub-item 0: Volume Controller Card
                    Rectangle {
                        width: 580
                        height: 90
                        radius: 6
                        color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#142848"
                        border.color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#30ffffff"
                        border.width: 2

                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Row {
                                width: parent.width
                                Text {
                                    text: "Master Volume"
                                    color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#0a1d3d" : "#ffffff"
                                    font.pixelSize: 17
                                    font.weight: Font.Medium
                                }
                                Text {
                                    anchors.right: parent.right
                                    text: systemManager.systemVolume + "%"
                                    color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#006FCD" : "#80c0ff"
                                    font.pixelSize: 17
                                    font.weight: Font.Bold
                                }
                            }

                            Row {
                                spacing: 14
                                anchors.horizontalCenter: parent.horizontalCenter

                                Text {
                                    text: "◀"
                                    color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#0a1d3d" : "#a0c0e8"
                                    font.pixelSize: 15
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Rectangle {
                                    width: 380
                                    height: 12
                                    radius: 6
                                    color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#d0e0f5" : "#0c1a32"
                                    border.color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#90b8e8" : "#204070"
                                    border.width: 1

                                    Rectangle {
                                        width: Math.max(4, parent.width * (systemManager.systemVolume / 100.0))
                                        height: parent.height
                                        radius: 6
                                        color: "#006FCD"
                                    }
                                }

                                Text {
                                    text: "▶"
                                    color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#0a1d3d" : "#a0c0e8"
                                    font.pixelSize: 15
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    // Sub-item 1: Mute Master Audio Card
                    Rectangle {
                        width: 580
                        height: 60
                        radius: 6
                        color: (root.activePane === 1 && root.rightSelectedIndex === 1) ? "#ffffff" : "#142848"
                        border.color: (root.activePane === 1 && root.rightSelectedIndex === 1) ? "#ffffff" : "#30ffffff"
                        border.width: 2

                        Row {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 14

                            Image {
                                width: 24
                                height: 24
                                source: systemManager.isMuted ? "qrc:/assets/icons/sound_mute.svg" : "qrc:/assets/icons/sound.svg"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: systemManager.isMuted ? "Unmute Master Audio" : "Mute Master Audio"
                                color: (root.activePane === 1 && root.rightSelectedIndex === 1) ? "#0a1d3d" : "#ffffff"
                                font.pixelSize: 18
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.activePane = 1;
                                root.rightSelectedIndex = 1;
                                systemManager.setIsMuted(!systemManager.isMuted);
                                soundController.playConfirm();
                            }
                        }
                    }

                    // Sub-item 2: BGM Card
                    Rectangle {
                        width: 580
                        height: 60
                        radius: 6
                        color: (root.activePane === 1 && root.rightSelectedIndex === 2) ? "#ffffff" : "#142848"
                        border.color: (root.activePane === 1 && root.rightSelectedIndex === 2) ? "#ffffff" : "#30ffffff"
                        border.width: 2

                        Row {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 14

                            Image {
                                width: 24
                                height: 24
                                source: "qrc:/assets/icons/sound.svg"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: soundController.bgmEnabled ? "Disable Home Screen Music (BGM)" : "Enable Home Screen Music (BGM)"
                                color: (root.activePane === 1 && root.rightSelectedIndex === 2) ? "#0a1d3d" : "#ffffff"
                                font.pixelSize: 18
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.activePane = 1;
                                root.rightSelectedIndex = 2;
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

                    Rectangle {
                        width: 580
                        height: 60
                        radius: 6
                        color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#142848"
                        border.color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#30ffffff"
                        border.width: 2

                        Row {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 14

                            Image {
                                width: 24
                                height: 24
                                source: "qrc:/assets/icons/rest_mode.svg"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Enter Rest Mode Now (Suspend)"
                                color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#0a1d3d" : "#ffffff"
                                font.pixelSize: 18
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.activePane = 1;
                                root.rightSelectedIndex = 0;
                                systemManager.enterRestMode();
                                soundController.playConfirm();
                            }
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // CONSOLE NAVIGATION HANDLERS
    // ==========================================
    function handleUp() {
        if (activePane === 0) {
            if (selectedCategory > 0) {
                selectedCategory--;
                rightSelectedIndex = 0;
                soundController.playTick();
                return true;
            }
        } else {
            if (rightSelectedIndex > 0) {
                rightSelectedIndex--;
                soundController.playTick();
                return true;
            }
        }
        return false;
    }

    function handleDown() {
        if (activePane === 0) {
            if (selectedCategory < categories.length - 1) {
                selectedCategory++;
                rightSelectedIndex = 0;
                soundController.playTick();
                return true;
            }
        } else {
            var maxItems = getMaxRightItems();
            if (rightSelectedIndex < maxItems - 1) {
                rightSelectedIndex++;
                soundController.playTick();
                return true;
            }
        }
        return false;
    }

    function handleLeft() {
        if (activePane === 1) {
            // If on Volume slider in Sound category, decrease volume
            if (selectedCategory === 1 && rightSelectedIndex === 0) {
                systemManager.setSystemVolume(Math.max(0, systemManager.systemVolume - 5));
                soundController.playTick();
                return true;
            }
            // Otherwise, return focus to Left category list
            activePane = 0;
            soundController.playTick();
            return true;
        }
        return false;
    }

    function handleRight() {
        if (activePane === 0) {
            // Move into right pane if category has interactive items
            var maxItems = getMaxRightItems();
            if (maxItems > 0) {
                activePane = 1;
                rightSelectedIndex = 0;
                soundController.playTick();
                return true;
            }
        } else if (activePane === 1) {
            // If on Volume slider, increase volume
            if (selectedCategory === 1 && rightSelectedIndex === 0) {
                systemManager.setSystemVolume(Math.min(100, systemManager.systemVolume + 5));
                soundController.playTick();
                return true;
            }
        }
        return false;
    }

    function handleConfirm() {
        if (activePane === 0) {
            var maxItems = getMaxRightItems();
            if (maxItems > 0) {
                activePane = 1;
                rightSelectedIndex = 0;
                soundController.playConfirm();
                return true;
            }
        } else {
            triggerRightAction();
            return true;
        }
        return false;
    }

    function handleBack() {
        if (activePane === 1) {
            activePane = 0;
            soundController.playBack();
            return true; // handled internally
        }
        return false; // let parent close settings
    }

    function getMaxRightItems() {
        if (selectedCategory === 1) return 3; // Volume, Mute, BGM
        if (selectedCategory === 5) return 1; // Rest Mode
        return 0;
    }

    function triggerRightAction() {
        soundController.playConfirm();
        if (selectedCategory === 1) {
            if (rightSelectedIndex === 1) {
                systemManager.setIsMuted(!systemManager.isMuted);
            } else if (rightSelectedIndex === 2) {
                soundController.setBgmEnabled(!soundController.bgmEnabled);
            }
        } else if (selectedCategory === 5) {
            if (rightSelectedIndex === 0) {
                systemManager.enterRestMode();
            }
        }
    }
}
