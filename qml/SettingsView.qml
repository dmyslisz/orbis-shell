import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent

    property bool isOpen: false

    // 0 = Categories List, 1 = Category Full-Screen Sub-Page
    property int currentLevel: 0
    property int selectedCategory: 0
    property int subSelectedIndex: 0

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

        // ==========================================
        // TOP HEADER
        // ==========================================
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
                    source: "qrc:/assets/icons/settings.svg"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.currentLevel === 0 ? "Settings" : ("Settings > " + root.categories[root.selectedCategory].name)
                    color: "#ffffff"
                    font.pixelSize: 30
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
                    GamepadBadge { button: "A"; size: 20; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Select"; color: "#ffffff"; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                }

                Row {
                    spacing: 8
                    GamepadBadge { button: "B"; size: 20; anchors.verticalCenter: parent.verticalCenter }
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

        // ==========================================
        // LEVEL 0: FULL-SCREEN CATEGORIES LIST
        // ==========================================
        Item {
            id: level0Container
            anchors.top: header.bottom
            anchors.topMargin: 20
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 70
            visible: root.currentLevel === 0

            ListView {
                id: catList
                anchors.fill: parent
                clip: true
                spacing: 8
                model: root.categories

                delegate: Item {
                    required property int index
                    required property var modelData
                    width: catList.width
                    height: 64

                    readonly property bool isCurrent: root.selectedCategory === index && root.currentLevel === 0

                    Rectangle {
                        anchors.fill: parent
                        radius: 2
                        color: isCurrent ? "#16325c" : "transparent"
                        border.color: isCurrent ? "#ffffff" : "transparent"
                        border.width: isCurrent ? 2.5 : 0

                        // Bottom separator line when not focused
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: "#18ffffff"
                            visible: !isCurrent
                        }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 24
                            anchors.rightMargin: 24
                            spacing: 20

                            Image {
                                width: 26
                                height: 26
                                source: modelData.icon
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: isCurrent ? 1.0 : 0.8
                            }

                            Text {
                                text: modelData.name
                                color: "#ffffff"
                                font.pixelSize: 20
                                font.weight: isCurrent ? Font.Medium : Font.Normal
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Right chevron arrow
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 24
                            anchors.verticalCenter: parent.verticalCenter
                            text: "›"
                            color: isCurrent ? "#ffffff" : "#7090b8"
                            font.pixelSize: 28
                            font.weight: Font.Light
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.selectedCategory = index;
                                root.subSelectedIndex = 0;
                                root.currentLevel = 1;
                                soundController.playConfirm();
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // LEVEL 1: FULL-SCREEN CATEGORY DETAIL PAGE
        // ==========================================
        Item {
            id: level1Container
            anchors.top: header.bottom
            anchors.topMargin: 30
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 70
            visible: root.currentLevel === 1

            // Category 0: System Information
            Column {
                visible: root.selectedCategory === 0
                spacing: 20
                width: parent.width

                Repeater {
                    model: [
                        { label: "Operating System", value: (root.sysInfo.osName ? root.sysInfo.osName : "Fedora Linux 44") },
                        { label: "Kernel Version", value: (root.sysInfo.kernelVersion ? root.sysInfo.kernelVersion : "Linux 6.x") },
                        { label: "Architecture", value: (root.sysInfo.architecture ? root.sysInfo.architecture : "x86_64") },
                        { label: "Desktop Session", value: "Orbis OS Shell (Native Wayland / X11)" },
                        { label: "System Memory", value: (root.sysInfo.totalRam ? root.sysInfo.totalRam : "Standard Unified Memory") },
                        { label: "Display Mode", value: "1920x1080 @ 60 Hz (Hardware Accelerated Sapphire Wave)" }
                    ]

                    Rectangle {
                        required property var modelData
                        width: parent.width
                        height: 58
                        radius: 4
                        color: "#0e1e3a"
                        border.color: "#20ffffff"
                        border.width: 1

                        Item {
                            anchors.fill: parent
                            anchors.margins: 20
                            Text {
                                text: modelData.label
                                color: "#80a8d8"
                                font.pixelSize: 18
                                font.weight: Font.Medium
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                anchors.right: parent.right
                                text: modelData.value
                                color: "#ffffff"
                                font.pixelSize: 18
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }

            // Category 1: Sound and Screen
            Column {
                visible: root.selectedCategory === 1
                spacing: 16
                width: parent.width

                // 0. Master Volume Stepper Card
                Rectangle {
                    width: parent.width
                    height: 84
                    radius: 4
                    color: root.subSelectedIndex === 0 ? "#16325c" : "#0e1e3a"
                    border.color: root.subSelectedIndex === 0 ? "#ffffff" : "#20ffffff"
                    border.width: root.subSelectedIndex === 0 ? 2.5 : 1

                    Item {
                        anchors.fill: parent
                        anchors.margins: 20

                        Column {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4
                            Text {
                                text: "Master Audio Volume"
                                color: "#ffffff"
                                font.pixelSize: 19
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: "Adjust output volume via PipeWire sink"
                                color: root.subSelectedIndex === 0 ? "#b0d0f8" : "#80a8d8"
                                font.pixelSize: 14
                            }
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 16

                            Text {
                                text: "◀"
                                color: "#ffffff"
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 280
                                height: 14
                                radius: 7
                                color: "#0a1628"
                                border.color: root.subSelectedIndex === 0 ? "#80b0f0" : "#204070"
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    width: Math.max(6, parent.width * (systemManager.systemVolume / 100.0))
                                    height: parent.height
                                    radius: 7
                                    color: "#006FCD"
                                }
                            }

                            Text {
                                text: "▶"
                                color: "#ffffff"
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: systemManager.systemVolume + "%"
                                color: "#ffffff"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.subSelectedIndex = 0;
                        }
                    }
                }

                // 1. Mute Audio Toggle Card
                Rectangle {
                    width: parent.width
                    height: 72
                    radius: 4
                    color: root.subSelectedIndex === 1 ? "#16325c" : "#0e1e3a"
                    border.color: root.subSelectedIndex === 1 ? "#ffffff" : "#20ffffff"
                    border.width: root.subSelectedIndex === 1 ? 2.5 : 1

                    Item {
                        anchors.fill: parent
                        anchors.margins: 20

                        Column {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4
                            Text {
                                text: "Mute System Audio"
                                color: "#ffffff"
                                font.pixelSize: 19
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: systemManager.isMuted ? "All sound output currently muted" : "Audio is active"
                                color: root.subSelectedIndex === 1 ? "#b0d0f8" : "#80a8d8"
                                font.pixelSize: 14
                            }
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 80
                            height: 32
                            radius: 16
                            color: systemManager.isMuted ? "#ef5350" : (root.subSelectedIndex === 1 ? "#006FCD" : "#204278")

                            Text {
                                anchors.centerIn: parent
                                text: systemManager.isMuted ? "MUTED" : "ON"
                                color: "#ffffff"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.subSelectedIndex = 1;
                            systemManager.setIsMuted(!systemManager.isMuted);
                            soundController.playConfirm();
                        }
                    }
                }

                // 2. Looping Home Screen Music (BGM) Card
                Rectangle {
                    width: parent.width
                    height: 72
                    radius: 4
                    color: root.subSelectedIndex === 2 ? "#16325c" : "#0e1e3a"
                    border.color: root.subSelectedIndex === 2 ? "#ffffff" : "#20ffffff"
                    border.width: root.subSelectedIndex === 2 ? 2.5 : 1

                    Item {
                        anchors.fill: parent
                        anchors.margins: 20

                        Column {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4
                            Text {
                                text: "Home Screen Music (BGM)"
                                color: "#ffffff"
                                font.pixelSize: 19
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: "Continuous seamless ambient audio loop in home menu"
                                color: root.subSelectedIndex === 2 ? "#b0d0f8" : "#80a8d8"
                                font.pixelSize: 14
                            }
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 90
                            height: 32
                            radius: 16
                            color: soundController.bgmEnabled ? "#4caf50" : "#607d8b"

                            Text {
                                anchors.centerIn: parent
                                text: soundController.bgmEnabled ? "ENABLED" : "OFF"
                                color: "#ffffff"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.subSelectedIndex = 2;
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

                Rectangle {
                    width: parent.width
                    height: 140
                    radius: 8
                    color: "#0e1e3a"
                    border.color: "#20ffffff"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 16

                        Row {
                            width: parent.width
                            Text {
                                text: "System Drive Storage"
                                color: "#ffffff"
                                font.pixelSize: 20
                                font.weight: Font.DemiBold
                            }
                            Text {
                                anchors.right: parent.right
                                text: (root.sysInfo.diskFree ? root.sysInfo.diskFree : "Available") + " free of " + (root.sysInfo.diskTotal ? root.sysInfo.diskTotal : "Total")
                                color: "#a0c0e8"
                                font.pixelSize: 16
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 18
                            radius: 9
                            color: "#0a1628"
                            border.color: "#204070"
                            border.width: 1

                            Rectangle {
                                width: parent.width * 0.42
                                height: parent.height
                                radius: 9
                                color: "#006FCD"
                            }
                        }

                        Row {
                            spacing: 24
                            Row {
                                spacing: 8
                                Rectangle { width: 12; height: 12; radius: 3; color: "#006FCD"; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "Applications & Games"; color: "#80a8d8"; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
                            }
                            Row {
                                spacing: 8
                                Rectangle { width: 12; height: 12; radius: 3; color: "#0a1628"; border.color: "#204070"; border.width: 1; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "Free Space"; color: "#80a8d8"; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
                            }
                        }
                    }
                }
            }

            // Category 3: Network
            Column {
                visible: root.selectedCategory === 3
                spacing: 16
                width: parent.width

                Repeater {
                    model: [
                        { label: "Connection Status", value: systemManager.isOnline ? "Connected to Network" : "Offline" },
                        { label: "Connection Type", value: systemManager.networkType },
                        { label: "IP Address", value: systemManager.ipAddress.length > 0 ? systemManager.ipAddress : "192.168.1.100" },
                        { label: "Subsystem", value: "Linux NetworkManager / systemd-networkd" }
                    ]

                    Rectangle {
                        required property var modelData
                        width: parent.width
                        height: 58
                        radius: 4
                        color: "#0e1e3a"
                        border.color: "#20ffffff"
                        border.width: 1

                        Item {
                            anchors.fill: parent
                            anchors.margins: 20
                            Text {
                                text: modelData.label
                                color: "#80a8d8"
                                font.pixelSize: 18
                                font.weight: Font.Medium
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                anchors.right: parent.right
                                text: modelData.value
                                color: "#ffffff"
                                font.pixelSize: 18
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }

            // Category 4: Devices & Controllers
            Column {
                visible: root.selectedCategory === 4
                spacing: 24
                width: parent.width

                Rectangle {
                    width: parent.width
                    height: 120
                    radius: 8
                    color: "#0e1e3a"
                    border.color: "#20ffffff"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 28
                        spacing: 24

                        Image {
                            width: 64
                            height: 64
                            source: "qrc:/assets/icons/ControllerWhite.png"
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: gamepadManager.gamepadConnected ? gamepadManager.gamepadName : "Keyboard & Standard Controller"
                                color: "#ffffff"
                                font.pixelSize: 22
                                font.weight: Font.Medium
                            }
                            Text {
                                text: gamepadManager.gamepadConnected ? "Active SDL3 Gamepad Subsystem" : "Standard Input (evdev / X11 / Wayland)"
                                color: "#80a8d8"
                                font.pixelSize: 16
                            }
                        }
                    }
                }
            }

            // Category 5: Power Save Settings
            Column {
                visible: root.selectedCategory === 5
                spacing: 16
                width: parent.width

                Repeater {
                    model: [
                        { id: "rest", title: "Enter Rest Mode Now (Suspend)", desc: "Low power suspend; resume anytime instantly" },
                        { id: "poweroff", title: "Power Off System", desc: "Completely turn off the computer" },
                        { id: "restart", title: "Restart System", desc: "Reboot computer and relaunch session" }
                    ]

                    Rectangle {
                        required property int index
                        required property var modelData
                        width: parent.width
                        height: 72
                        radius: 4
                        color: root.subSelectedIndex === index ? "#16325c" : "#0e1e3a"
                        border.color: root.subSelectedIndex === index ? "#ffffff" : "#20ffffff"
                        border.width: root.subSelectedIndex === index ? 2.5 : 1

                        Row {
                            anchors.fill: parent
                            anchors.margins: 20
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4
                                Text {
                                    text: modelData.title
                                    color: "#ffffff"
                                    font.pixelSize: 19
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    text: modelData.desc
                                    color: root.subSelectedIndex === index ? "#b0d0f8" : "#80a8d8"
                                    font.pixelSize: 14
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.subSelectedIndex = index;
                                root.triggerSubAction();
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
        if (currentLevel === 0) {
            if (selectedCategory > 0) {
                selectedCategory--;
                soundController.playTick();
                return true;
            }
        } else {
            if (subSelectedIndex > 0) {
                subSelectedIndex--;
                soundController.playTick();
                return true;
            }
        }
        return false;
    }

    function handleDown() {
        if (currentLevel === 0) {
            if (selectedCategory < categories.length - 1) {
                selectedCategory++;
                soundController.playTick();
                return true;
            }
        } else {
            var maxItems = getMaxSubItems();
            if (subSelectedIndex < maxItems - 1) {
                subSelectedIndex++;
                soundController.playTick();
                return true;
            }
        }
        return false;
    }

    function handleLeft() {
        if (currentLevel === 1) {
            // If on Volume stepper in Sound & Screen, decrease volume
            if (selectedCategory === 1 && subSelectedIndex === 0) {
                systemManager.setSystemVolume(Math.max(0, systemManager.systemVolume - 5));
                soundController.playTick();
                return true;
            }
            // Otherwise, slide back to categories list
            currentLevel = 0;
            soundController.playBack();
            return true;
        }
        return false;
    }

    function handleRight() {
        if (currentLevel === 0) {
            currentLevel = 1;
            subSelectedIndex = 0;
            soundController.playConfirm();
            return true;
        } else if (currentLevel === 1) {
            // If on Volume stepper, increase volume
            if (selectedCategory === 1 && subSelectedIndex === 0) {
                systemManager.setSystemVolume(Math.min(100, systemManager.systemVolume + 5));
                soundController.playTick();
                return true;
            }
        }
        return false;
    }

    function handleConfirm() {
        if (currentLevel === 0) {
            currentLevel = 1;
            subSelectedIndex = 0;
            soundController.playConfirm();
            return true;
        } else {
            triggerSubAction();
            return true;
        }
    }

    function handleBack() {
        if (currentLevel === 1) {
            currentLevel = 0;
            soundController.playBack();
            return true;
        }
        return false; // let parent close Settings view
    }

    function getMaxSubItems() {
        if (selectedCategory === 1) return 3; // Volume, Mute, BGM
        if (selectedCategory === 5) return 3; // Rest, Turn off, Restart
        return 0;
    }

    function triggerSubAction() {
        soundController.playConfirm();
        if (selectedCategory === 1) {
            if (subSelectedIndex === 0) {
                systemManager.setSystemVolume(Math.min(100, systemManager.systemVolume + 5));
            } else if (subSelectedIndex === 1) {
                systemManager.setIsMuted(!systemManager.isMuted);
            } else if (subSelectedIndex === 2) {
                soundController.setBgmEnabled(!soundController.bgmEnabled);
            }
        } else if (selectedCategory === 5) {
            if (subSelectedIndex === 0) {
                systemManager.enterRestMode();
            } else if (subSelectedIndex === 1) {
                systemManager.turnOff();
            } else if (subSelectedIndex === 2) {
                systemManager.restart();
            }
        }
    }
}
