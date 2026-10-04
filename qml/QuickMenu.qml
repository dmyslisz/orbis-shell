import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent
    visible: root.isOpen || panel.x > -panel.width

    property bool isOpen: false
    property string userName: "Player 1"
    property string userAvatar: "qrc:/assets/avatars/avatar_luchador.svg"

    // 0 = Left Menu items, 1 = Right Detail items
    property int activePane: 0
    property int selectedIndex: 0
    property int rightSelectedIndex: 0

    signal actionTriggered(string actionId)
    signal closeRequested()

    readonly property var menuItems: [
        { id: "close_app", name: "Close Application", icon: "qrc:/assets/icons/close_app.svg" },
        { id: "sound_devices", name: "Sound/Devices", icon: "qrc:/assets/icons/sound_devices.svg" },
        { id: "music", name: "Music (BGM)", icon: "qrc:/assets/icons/sound.svg" },
        { id: "friends", name: "Friends", icon: "qrc:/assets/icons/quickmenu_friends.png" },
        { id: "power", name: "Power", icon: "qrc:/assets/icons/power.svg" }
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

                // User Info Header
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
                            text: "Online"
                            color: "#4caf50"
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
                                color: isFocused ? "#ffffff" : (isCurrent ? "#244270" : "transparent")
                                border.color: isFocused ? "#ffffff" : "transparent"
                                border.width: isFocused ? 2 : 0

                                Behavior on color { ColorAnimation { duration: 120 } }

                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 14

                                    Image {
                                        width: 24
                                        height: 24
                                        source: modelData.icon
                                        fillMode: Image.PreserveAspectFit
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData.name
                                        color: isFocused ? "#0a1d3d" : "#ffffff"
                                        font.pixelSize: 17
                                        font.weight: isCurrent ? Font.Medium : Font.Normal
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    root.selectedIndex = index;
                                    root.activePane = 0;
                                    soundController.playTick();
                                }
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // RIGHT COLUMN: CONSOLE ACTION ITEMS
        // ==========================================
        Item {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: leftCol.right
            anchors.right: parent.right
            anchors.margins: 36
            anchors.topMargin: 70

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
                    text: processLauncher.isAppRunning 
                          ? "Currently running: " + processLauncher.currentAppName 
                          : "No application is currently running."
                    color: "#a0c0e8"
                    font.pixelSize: 15
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                // Console Action Card
                Rectangle {
                    visible: processLauncher.isAppRunning
                    width: parent.width - 20
                    height: 56
                    radius: 4
                    color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#142848"
                    border.color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#30ffffff"
                    border.width: 2

                    Row {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Image {
                            width: 20
                            height: 20
                            source: "qrc:/assets/icons/buttons/PS4_Cross.png"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Close " + processLauncher.currentAppName
                            color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#0a1d3d" : "#ffffff"
                            font.pixelSize: 17
                            font.weight: Font.Medium
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
                    height: 86
                    radius: 6
                    color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#142848"
                    border.color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#30ffffff"
                    border.width: 2

                    Column {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Row {
                            width: parent.width
                            Text {
                                text: "Master Volume"
                                color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#0a1d3d" : "#ffffff"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                            }
                            Text {
                                anchors.right: parent.right
                                text: systemManager.systemVolume + "%"
                                color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#006FCD" : "#80c0ff"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                            }
                        }

                        // Console Progress Bar with Steppers
                        Row {
                            spacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter

                            Text {
                                text: "◀"
                                color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#0a1d3d" : "#a0c0e8"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 260
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
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // Sub-item 1: Mute Audio Card
                Rectangle {
                    width: parent.width - 20
                    height: 56
                    radius: 4
                    color: (root.activePane === 1 && root.rightSelectedIndex === 1) ? "#ffffff" : "#142848"
                    border.color: (root.activePane === 1 && root.rightSelectedIndex === 1) ? "#ffffff" : "#30ffffff"
                    border.width: 2

                    Row {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Image {
                            width: 22
                            height: 22
                            source: systemManager.isMuted ? "qrc:/assets/icons/sound_mute.svg" : "qrc:/assets/icons/sound.svg"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: systemManager.isMuted ? "Unmute Audio" : "Mute Audio"
                            color: (root.activePane === 1 && root.rightSelectedIndex === 1) ? "#0a1d3d" : "#ffffff"
                            font.pixelSize: 17
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            systemManager.setIsMuted(!systemManager.isMuted);
                            soundController.playConfirm();
                        }
                    }
                }
            }

            // 3. Music (BGM) Pane
            Column {
                visible: root.selectedIndex === 2
                spacing: 22
                width: parent.width

                Text {
                    text: "Background Music (BGM)"
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }

                // Sub-item 0: Toggle BGM Card
                Rectangle {
                    width: parent.width - 20
                    height: 56
                    radius: 4
                    color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#142848"
                    border.color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#ffffff" : "#30ffffff"
                    border.width: 2

                    Row {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Image {
                            width: 20
                            height: 20
                            source: "qrc:/assets/icons/buttons/PS4_Cross.png"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: soundController.bgmEnabled ? "Mute Home Screen Music" : "Enable Home Screen Music"
                            color: (root.activePane === 1 && root.rightSelectedIndex === 0) ? "#0a1d3d" : "#ffffff"
                            font.pixelSize: 17
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            soundController.setBgmEnabled(!soundController.bgmEnabled);
                            soundController.playConfirm();
                        }
                    }
                }
            }

            // 4. Friends Pane
            Column {
                visible: root.selectedIndex === 3
                spacing: 18
                width: parent.width

                Text {
                    text: "Friends Online (4)"
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }

                Repeater {
                    model: [
                        { name: "Alex", status: "Playing Steam Game", color: "#4caf50" },
                        { name: "Chris", status: "Online", color: "#4caf50" },
                        { name: "Sam", status: "In Voice Party", color: "#2196f3" },
                        { name: "Morgan", status: "Away", color: "#ffa726" }
                    ]

                    Rectangle {
                        required property var modelData
                        width: parent.width - 20
                        height: 52
                        radius: 4
                        color: "#10223e"
                        border.color: "#20ffffff"
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12

                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
                                color: modelData.color
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.name + " (" + modelData.status + ")"
                                color: "#ffffff"
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }

            // 5. Power Pane
            Column {
                visible: root.selectedIndex === 4
                spacing: 14
                width: parent.width

                Text {
                    text: "Power Options"
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }

                Repeater {
                    model: [
                        { id: "rest", title: "Enter Rest Mode (Suspend)", icon: "qrc:/assets/icons/rest_mode.svg" },
                        { id: "poweroff", title: "Turn Off System (Power Off)", icon: "qrc:/assets/icons/power.svg" },
                        { id: "reboot", title: "Restart System (Reboot)", icon: "qrc:/assets/icons/restart.svg" }
                    ]

                    Rectangle {
                        required property int index
                        required property var modelData
                        width: parent.width - 20
                        height: 56
                        radius: 4
                        color: (root.activePane === 1 && root.rightSelectedIndex === index) ? "#ffffff" : "#142848"
                        border.color: (root.activePane === 1 && root.rightSelectedIndex === index) ? "#ffffff" : "#30ffffff"
                        border.width: 2

                        Row {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 14

                            Image {
                                width: 24
                                height: 24
                                source: modelData.icon
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.title
                                color: (root.activePane === 1 && root.rightSelectedIndex === index) ? "#0a1d3d" : "#ffffff"
                                font.pixelSize: 17
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.activePane = 1;
                                root.rightSelectedIndex = index;
                                root.triggerRightAction();
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
        if (activePane === 1) {
            // If on Volume slider, decrease volume
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
            // If on Volume slider, increase volume
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
            // Move into right pane
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
            return true; // handled internally
        }
        return false; // let parent close menu
    }

    function getMaxRightItems() {
        if (selectedIndex === 0) return processLauncher.isAppRunning ? 1 : 0;
        if (selectedIndex === 1) return 2; // 0 = Volume, 1 = Mute
        if (selectedIndex === 2) return 1; // 0 = Toggle BGM
        if (selectedIndex === 3) return 0;
        if (selectedIndex === 4) return 3; // 0 = Rest, 1 = Off, 2 = Reboot
        return 0;
    }

    function triggerRightAction() {
        soundController.playConfirm();
        if (selectedIndex === 0) {
            processLauncher.terminateCurrentApp();
        } else if (selectedIndex === 1) {
            if (rightSelectedIndex === 1) {
                systemManager.setIsMuted(!systemManager.isMuted);
            }
        } else if (selectedIndex === 2) {
            soundController.setBgmEnabled(!soundController.bgmEnabled);
        } else if (selectedIndex === 4) {
            if (rightSelectedIndex === 0) {
                systemManager.enterRestMode();
            } else if (rightSelectedIndex === 1) {
                systemManager.turnOff();
            } else if (rightSelectedIndex === 2) {
                systemManager.restart();
            }
        }
    }
}
