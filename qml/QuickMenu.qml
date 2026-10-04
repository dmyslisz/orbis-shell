import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: parent.width
    height: 1080

    property bool isOpen: false
    property string userName: "Player 1"
    property string userAvatar: "qrc:/assets/avatars/avatar_luchador.svg"
    property int selectedIndex: 0

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
            onClicked: root.closeRequested()
        }
    }

    // Slide-out panel from the left edge
    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 720
        color: "#f008162e"
        border.color: "#25ffffff"
        border.width: 1

        x: root.isOpen ? 0 : -width

        Behavior on x {
            NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
        }

        // Left Navigation Column (300px)
        Rectangle {
            id: leftCol
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 320
            color: "#081022"

            Column {
                anchors.fill: parent
                anchors.margins: 32
                anchors.topMargin: 64
                spacing: 24

                // User Info Banner
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

                // Nav items
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

                            readonly property bool isSelected: root.isOpen && root.selectedIndex === index

                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: isSelected ? "#ffffff" : "transparent"

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
                                        color: isSelected ? "#0a1d3d" : "#ffffff"
                                        font.pixelSize: 17
                                        font.weight: isSelected ? Font.Medium : Font.Normal
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Right Detail Column (400px)
        Item {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: leftCol.right
            anchors.right: parent.right
            anchors.margins: 36
            anchors.topMargin: 80

            // Close App View
            Column {
                visible: root.selectedIndex === 0
                spacing: 24
                width: parent.width

                Text {
                    text: "Close Application"
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.weight: Font.Medium
                }

                Text {
                    text: processLauncher.isAppRunning 
                          ? "Currently running: " + processLauncher.currentAppName 
                          : "No application is currently running."
                    color: "#a0c0e8"
                    font.pixelSize: 16
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                Button {
                    visible: processLauncher.isAppRunning
                    text: "Close " + processLauncher.currentAppName
                    highlighted: true
                    onClicked: {
                        processLauncher.terminateCurrentApp();
                        soundController.playConfirm();
                    }
                }
            }

            // Sound / Devices View
            Column {
                visible: root.selectedIndex === 1
                spacing: 24
                width: parent.width

                Text {
                    text: "Sound / Devices"
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.weight: Font.Medium
                }

                Column {
                    spacing: 8
                    width: parent.width

                    Row {
                        spacing: 12
                        Text { text: "Master Volume:"; color: "#a0c0e8"; font.pixelSize: 16 }
                        Text { text: systemManager.systemVolume + "%"; color: "#ffffff"; font.pixelSize: 16; font.weight: Font.Bold }
                    }

                    Slider {
                        width: parent.width - 40
                        from: 0
                        to: 100
                        value: systemManager.systemVolume
                        onMoved: systemManager.setSystemVolume(value)
                    }
                }

                Row {
                    spacing: 16
                    Button {
                        text: systemManager.isMuted ? "Unmute Audio" : "Mute Audio"
                        onClicked: {
                            systemManager.setIsMuted(!systemManager.isMuted);
                            soundController.playConfirm();
                        }
                    }
                }
            }

            // Music View (BGM)
            Column {
                visible: root.selectedIndex === 2
                spacing: 24
                width: parent.width

                Text {
                    text: "Background Music (BGM)"
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.weight: Font.Medium
                }

                Text {
                    text: soundController.bgmEnabled ? "Orbis Home Screen Music is Playing" : "Home Screen Music is Muted"
                    color: "#a0c0e8"
                    font.pixelSize: 16
                }

                Button {
                    text: soundController.bgmEnabled ? "Mute BGM" : "Enable BGM"
                    highlighted: true
                    onClicked: {
                        soundController.setBgmEnabled(!soundController.bgmEnabled);
                        soundController.playConfirm();
                    }
                }
            }

            // Friends View
            Column {
                visible: root.selectedIndex === 3
                spacing: 20
                width: parent.width

                Text {
                    text: "Friends Online (4)"
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.weight: Font.Medium
                }

                Repeater {
                    model: ["Alex (Playing Steam)", "Chris (Online)", "Sam (In Party)", "Morgan (Away)"]
                    Row {
                        spacing: 12
                        Rectangle { width: 10; height: 10; radius: 5; color: "#4caf50"; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: modelData; color: "#ffffff"; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }

            // Power View
            Column {
                visible: root.selectedIndex === 4
                spacing: 18
                width: parent.width

                Text {
                    text: "Power Options"
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.weight: Font.Medium
                }

                Button {
                    width: parent.width - 40
                    text: "Enter Rest Mode (Suspend)"
                    onClicked: {
                        systemManager.enterRestMode();
                        soundController.playConfirm();
                    }
                }

                Button {
                    width: parent.width - 40
                    text: "Turn Off System (Power Off)"
                    onClicked: {
                        systemManager.turnOff();
                        soundController.playConfirm();
                    }
                }

                Button {
                    width: parent.width - 40
                    text: "Restart System (Reboot)"
                    onClicked: {
                        systemManager.restart();
                        soundController.playConfirm();
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
        if (selectedIndex < menuItems.length - 1) {
            selectedIndex++;
            return true;
        }
        return false;
    }

    function adjustLeft() {
        if (selectedIndex === 1) {
            systemManager.setSystemVolume(Math.max(0, systemManager.systemVolume - 5));
            return true;
        }
        return false;
    }

    function adjustRight() {
        if (selectedIndex === 1) {
            systemManager.setSystemVolume(Math.min(100, systemManager.systemVolume + 5));
            return true;
        }
        return false;
    }

    function triggerCurrent() {
        var item = menuItems[selectedIndex];
        if (item.id === "close_app") {
            processLauncher.terminateCurrentApp();
            soundController.playConfirm();
        } else if (item.id === "music") {
            soundController.setBgmEnabled(!soundController.bgmEnabled);
            soundController.playConfirm();
        } else {
            actionTriggered(item.id);
        }
    }
}
