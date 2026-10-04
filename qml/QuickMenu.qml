import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent
    visible: root.isOpen || panel.x > -panel.width

    property bool isOpen: false
    property string userName: "User 1"
    property string userAvatar: "qrc:/assets/avatars/avatar_luchador.svg"

    // 0 = Left Menu items, 1 = Right Detail items
    property int activePane: 0
    property int selectedIndex: 0
    property int rightSelectedIndex: 0

    signal actionTriggered(string actionId)
    signal closeRequested()
    signal switchUserRequested()
    signal powerActionRequested(string actionId)

    readonly property var menuItems: [
        { id: "close_app", name: "Close Application", icon: "qrc:/assets/icons/close_app.svg" },
        { id: "sound_devices", name: "Sound / Devices", icon: "qrc:/assets/icons/sound_devices.svg" },
        { id: "power", name: "Power", icon: "qrc:/assets/icons/power.svg" }
    ]

    readonly property var powerOptions: [
        { id: "rest", name: "Enter Rest Mode", icon: "qrc:/assets/icons/rest_mode.svg" },
        { id: "poweroff", name: "Turn Off System", icon: "qrc:/assets/icons/power.svg" },
        { id: "reboot", name: "Restart System", icon: "qrc:/assets/icons/restart.svg" },
        { id: "switch_user", name: "Switch User", icon: "qrc:/assets/icons/profile.svg" },
        { id: "logout", name: "Log Out", icon: "qrc:/assets/icons/power.svg" },
        { id: "close_shell", name: "Close Orbis Shell", icon: "qrc:/assets/icons/close_app.svg" }
    ]

    // Dim background
    Rectangle {
        anchors.fill: parent
        color: "#80000000"
        opacity: root.isOpen ? 1.0 : 0.0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation { duration: 180 }
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.isOpen
            onClicked: root.closeRequested()
        }
    }

    // Slide-out panel from the left edge
    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 760
        color: "#f0061228"
        border.color: "#25ffffff"
        border.width: 1

        x: root.isOpen ? 0 : -width

        Behavior on x {
            NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
        }

        // ==========================================
        // LEFT COLUMN: MENU ITEMS
        // ==========================================
        Rectangle {
            id: leftCol
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 330
            color: "#081022"

            Column {
                anchors.fill: parent
                anchors.margins: 28
                anchors.topMargin: 56
                spacing: 20

                // User Info Header (Clean, no online or PlayStation branding)
                Row {
                    spacing: 14
                    anchors.left: parent.left

                    Rectangle {
                        width: 44
                        height: 44
                        radius: 6
                        color: "#18325a"
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: root.userAvatar
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: root.userName
                            color: "#ffffff"
                            font.pixelSize: 18
                            font.weight: Font.Medium
                        }

                        Text {
                            text: "Active Profile"
                            color: "#80a8d8"
                            font.pixelSize: 13
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#20ffffff"
                }

                // Menu items list
                Column {
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: root.menuItems

                        Item {
                            required property int index
                            required property var modelData
                            width: parent.width
                            height: 54

                            readonly property bool isCurrent: root.selectedIndex === index
                            readonly property bool isFocused: root.isOpen && isCurrent && root.activePane === 0

                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: isFocused ? "#16325c" : (isCurrent ? "#14294a" : "transparent")
                                border.color: isFocused ? "#ffffff" : "transparent"
                                border.width: isFocused ? 2.5 : 0

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    spacing: 14

                                    Image {
                                        width: 24
                                        height: 24
                                        source: modelData.icon
                                        fillMode: Image.PreserveAspectFit
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: isFocused ? 1.0 : 0.8
                                    }

                                    Text {
                                        text: modelData.name
                                        color: "#ffffff"
                                        font.pixelSize: 17
                                        font.weight: isFocused ? Font.Medium : Font.Normal
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        root.selectedIndex = index;
                                        root.activePane = 0;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Vertical divider
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: leftCol.right
            width: 1
            color: "#25ffffff"
        }

        // ==========================================
        // RIGHT COLUMN: CONSOLE CARDS & STEPPERS
        // ==========================================
        Item {
            id: rightPane
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: leftCol.right
            anchors.right: parent.right
            anchors.margins: 28
            anchors.topMargin: 56

            // 1. Close Application Pane
            Column {
                visible: root.selectedIndex === 0
                spacing: 24
                width: parent.width

                Text {
                    text: "Close Application"
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }

                Text {
                    text: processLauncher.isAppRunning ? ("Active: " + processLauncher.currentAppName) : "No application is currently running."
                    color: "#a0c0e8"
                    font.pixelSize: 16
                }

                Rectangle {
                    visible: processLauncher.isAppRunning
                    width: parent.width - 20
                    height: 56
                    radius: 4
                    readonly property bool isCloseSelected: root.activePane === 1 && root.rightSelectedIndex === 0
                    color: isCloseSelected ? "#16325c" : "#142848"
                    border.color: isCloseSelected ? "#ffffff" : "#30ffffff"
                    border.width: isCloseSelected ? 2.5 : 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Image {
                            width: 22
                            height: 22
                            source: "qrc:/assets/icons/close_app.svg"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Close " + processLauncher.currentAppName
                            color: "#ffffff"
                            font.pixelSize: 17
                            font.weight: isCloseSelected ? Font.DemiBold : Font.Normal
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            processLauncher.terminateCurrentApp();
                            soundController.playConfirm();
                        }
                    }
                }
            }

            // 2. Sound / Devices Pane
            Column {
                visible: root.selectedIndex === 1
                spacing: 22
                width: parent.width

                Text {
                    text: "Sound / Devices"
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }

                // Sub-item 0: Volume Controller Card
                Rectangle {
                    width: parent.width - 20
                    height: 96
                    radius: 4
                    color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#16325c" : "#142848"
                    border.color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#30ffffff"
                    border.width: (root.activePane === 1 && root.rightSelectedIndex === 0) ? 2.5 : 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        Item {
                            width: parent.width
                            height: 22

                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Master Volume"
                                color: "#ffffff"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: systemManager.systemVolume + "%"
                                color: "#ffffff"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                            }
                        }

                        // Console Progress Bar with Steppers
                        Row {
                            spacing: 12
                            anchors.horizontalCenter: parent.horizontalCenter

                            // Decrement button
                            Rectangle {
                                width: 28
                                height: 28
                                radius: 4
                                color: "#1a355a"
                                border.color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#4070a8"
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "◀"
                                    color: "#ffffff"
                                    font.pixelSize: 13
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        root.activePane = 1;
                                        root.rightSelectedIndex = 0;
                                        systemManager.setSystemVolume(Math.max(0, systemManager.systemVolume - 5));
                                        soundController.playTick();
                                    }
                                }
                            }

                            // Stepper bar
                            Rectangle {
                                width: 240
                                height: 14
                                radius: 7
                                color: "#0c1a32"
                                border.color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#204070"
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    width: Math.max(6, parent.width * (systemManager.systemVolume / 100.0))
                                    height: parent.height
                                    radius: 7
                                    color: "#006FCD"
                                }
                            }

                            // Increment button
                            Rectangle {
                                width: 28
                                height: 28
                                radius: 4
                                color: "#1a355a"
                                border.color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#4070a8"
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "▶"
                                    color: "#ffffff"
                                    font.pixelSize: 13
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        root.activePane = 1;
                                        root.rightSelectedIndex = 0;
                                        systemManager.setSystemVolume(Math.min(100, systemManager.systemVolume + 5));
                                        soundController.playTick();
                                    }
                                }
                            }
                        }
                    }
                }

                // Sub-item 1: Mute Audio Card
                Rectangle {
                    width: parent.width - 20
                    height: 56
                    radius: 4
                    color: (root.activePane === 1 && root.rightSelectedIndex === 1) ? "#16325c" : "#142848"
                    border.color: (root.activePane === 1 && root.rightSelectedIndex === 1) ? "#ffffff" : "#30ffffff"
                    border.width: (root.activePane === 1 && root.rightSelectedIndex === 1) ? 2.5 : 1

                    Item {
                        anchors.fill: parent
                        anchors.margins: 16

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12

                            Image {
                                width: 22
                                height: 22
                                source: "qrc:/assets/icons/sound_mute.svg"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: systemManager.isMuted ? "Unmute Audio" : "Mute Audio"
                                color: "#ffffff"
                                font.pixelSize: 17
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            radius: 7
                            color: systemManager.isMuted ? "#ef5350" : "#4caf50"
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
            }

            // 3. Power Pane
            Column {
                visible: root.selectedIndex === 2
                spacing: 8
                width: parent.width

                Text {
                    text: "Power"
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }

                Repeater {
                    model: root.powerOptions

                    Item {
                        required property int index
                        required property var modelData
                        width: parent.width - 20
                        height: 52

                        readonly property bool isSelected: root.activePane === 1 && root.rightSelectedIndex === index

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: isSelected ? "#16325c" : "#142848"
                            border.color: isSelected ? "#ffffff" : "#30ffffff"
                            border.width: isSelected ? 2.5 : 1

                            Row {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 12

                                Image {
                                    width: 22
                                    height: 22
                                    source: modelData.icon
                                    fillMode: Image.PreserveAspectFit
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.name
                                    color: "#ffffff"
                                    font.pixelSize: 16
                                    font.weight: isSelected ? Font.DemiBold : Font.Normal
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.rightSelectedIndex = index;
                                root.triggerRightAction();
                            }
                        }
                    }
                }
            }
        }

        // Bottom Action hints
        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            anchors.left: parent.left
            anchors.leftMargin: 28
            spacing: 20

            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                GamepadBadge { button: "A"; size: 18; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Select"; color: "#ffffff"; font.pixelSize: 15; anchors.verticalCenter: parent.verticalCenter }
            }

            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                GamepadBadge { button: "B"; size: 18; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Back"; color: "#ffffff"; font.pixelSize: 15; anchors.verticalCenter: parent.verticalCenter }
            }
        }
    }

    // ==========================================
    // CONSOLE NAVIGATION HANDLERS
    // ==========================================
    function handleUp() {
        if (activePane === 0) {
            if (selectedIndex > 0) {
                selectedIndex--;
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
            if (selectedIndex < menuItems.length - 1) {
                selectedIndex++;
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
        if (activePane === 0) {
            // If on Sound/Devices in left pane, decrease volume directly
            if (selectedIndex === 1) {
                systemManager.setSystemVolume(Math.max(0, systemManager.systemVolume - 5));
                soundController.playTick();
                return true;
            }
        } else if (activePane === 1) {
            // If on Volume stepper, decrease volume
            if (selectedIndex === 1 && rightSelectedIndex === 0) {
                systemManager.setSystemVolume(Math.max(0, systemManager.systemVolume - 5));
                soundController.playTick();
                return true;
            }
            // Otherwise, move focus back to left column
            activePane = 0;
            soundController.playTick();
            return true;
        }
        return false;
    }

    function handleRight() {
        if (activePane === 0) {
            // Move focus to right pane
            activePane = 1;
            rightSelectedIndex = 0;
            soundController.playTick();
            return true;
        } else if (activePane === 1) {
            // If on Volume stepper, increase volume
            if (selectedIndex === 1 && rightSelectedIndex === 0) {
                systemManager.setSystemVolume(Math.min(100, systemManager.systemVolume + 5));
                soundController.playTick();
                return true;
            }
        }
        return false;
    }

    function handleConfirm() {
        if (activePane === 0) {
            activePane = 1;
            rightSelectedIndex = 0;
            soundController.playConfirm();
            return true;
        } else {
            triggerRightAction();
            return true;
        }
    }

    function handleBack() {
        if (activePane === 1) {
            activePane = 0;
            soundController.playBack();
            return true;
        }
        return false;
    }

    function getMaxRightItems() {
        if (selectedIndex === 0) return processLauncher.isAppRunning ? 1 : 0;
        if (selectedIndex === 1) return 2; // 0 = Volume, 1 = Mute
        if (selectedIndex === 2) return powerOptions.length;
        return 0;
    }

    function triggerRightAction() {
        soundController.playConfirm();
        if (selectedIndex === 0) {
            processLauncher.terminateCurrentApp();
        } else if (selectedIndex === 1) {
            if (rightSelectedIndex === 0) {
                // Stepping volume up with Confirm if desired
                systemManager.setSystemVolume(Math.min(100, systemManager.systemVolume + 5));
            } else if (rightSelectedIndex === 1) {
                systemManager.setIsMuted(!systemManager.isMuted);
            }
        } else if (selectedIndex === 2) {
            var pOpt = powerOptions[rightSelectedIndex];
            if (pOpt.id === "switch_user") {
                root.switchUserRequested();
            } else if (pOpt.id === "logout") {
                soundController.playLogout();
                root.switchUserRequested();
            } else {
                root.powerActionRequested(pOpt.id);
            }
        }
    }
}
