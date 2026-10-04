import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent

    property int selectedIndex: 0
    property bool isOptionsMenuOpen: false
    property int optionsSelectedIndex: 0
    property var keyboardItem: null

    signal userLoggedIn(var user)
    signal returnToWelcome()

    readonly property var usersList: configManager.users

    // Top-Left Orbis OS Wordmark & Emblem (Photo 2)
    Row {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 80
        anchors.topMargin: 56
        spacing: 16

        Image {
            width: 44
            height: 44
            source: "qrc:/assets/icons/launcher_logo.svg"
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "ORBIS OS"
            color: "#ffffff"
            font.pixelSize: 34
            font.weight: Font.DemiBold
            font.letterSpacing: 3
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Sub-header: Controller connected & Prompt (Photo 2)
    Column {
        anchors.left: parent.left
        anchors.leftMargin: 120
        anchors.top: parent.top
        anchors.topMargin: 190
        spacing: 10

        Row {
            spacing: 12
            anchors.left: parent.left

            Image {
                width: 24
                height: 24
                source: "qrc:/assets/icons/ControllerWhite.png"
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Wireless controller connected."
                color: "#c8ddfc"
                font.pixelSize: 18
                font.weight: Font.Normal
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Text {
            text: "Who is using this controller?"
            color: "#ffffff"
            font.pixelSize: 22
            font.weight: Font.Normal
        }
    }

    // Horizontal User Profiles Row (Photo 2)
    Row {
        id: usersRow
        anchors.left: parent.left
        anchors.leftMargin: 120
        anchors.top: parent.top
        anchors.topMargin: 330
        spacing: 32

        // Card 0: "New User" Card (+)
        Item {
            width: 170
            height: 240

            readonly property bool isSelected: root.selectedIndex === 0 && !root.isOptionsMenuOpen

            Column {
                anchors.fill: parent
                spacing: 16

                // Square Card with '+'
                Rectangle {
                    width: 170
                    height: 170
                    radius: 2
                    color: "#0f3675"
                    border.color: isSelected ? "#ffffff" : "#204a88"
                    border.width: isSelected ? 3.5 : 1
                    scale: isSelected ? 1.06 : 1.0

                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    Behavior on border.color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        color: "#ffffff"
                        font.pixelSize: 72
                        font.weight: Font.Light
                    }
                }

                // Name label below
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "New User"
                    color: isSelected ? "#ffffff" : "#a0c0e8"
                    font.pixelSize: 18
                    font.weight: isSelected ? Font.Medium : Font.Normal
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.selectedIndex = 0;
                    root.triggerCurrent();
                }
            }
        }

        // Subsequent Cards: Existing User Profiles (indices 1 .. usersList.length)
        Repeater {
            model: root.usersList

            Item {
                required property int index
                required property var modelData
                readonly property int cardIndex: index + 1
                width: 170
                height: 240

                readonly property bool isSelected: root.selectedIndex === cardIndex && !root.isOptionsMenuOpen

                Column {
                    anchors.fill: parent
                    spacing: 16

                    // Square Avatar Card with White Outline Selection
                    Rectangle {
                        width: 170
                        height: 170
                        radius: 2
                        color: "#0a1d3d"
                        border.color: isSelected ? "#ffffff" : "#1e3b68"
                        border.width: isSelected ? 3.5 : 1
                        clip: true
                        scale: isSelected ? 1.06 : 1.0

                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                        Behavior on border.color { ColorAnimation { duration: 100 } }

                        Image {
                            anchors.fill: parent
                            source: modelData.avatar ? modelData.avatar : "qrc:/assets/avatars/avatar_luchador.svg"
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    // User name label below
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.name ? modelData.name : "User " + (index + 1)
                        color: isSelected ? "#ffffff" : "#a0c0e8"
                        font.pixelSize: 18
                        font.weight: isSelected ? Font.Medium : Font.Normal
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.selectedIndex = cardIndex;
                        root.triggerCurrent();
                    }
                }
            }
        }
    }

    // Bottom Action Prompts Bar (Photo 2)
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 48
        spacing: 36

        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter
            Image {
                width: 22
                height: 22
                source: "qrc:/assets/icons/buttons/PS4_Cross.png"
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "Enter"
                color: "#ffffff"
                font.pixelSize: 17
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter
            Image {
                width: 22
                height: 22
                source: "qrc:/assets/icons/buttons/PS4_Circle.png"
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "Cancel"
                color: "#ffffff"
                font.pixelSize: 17
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter
            visible: root.selectedIndex > 0
            Image {
                width: 24
                height: 24
                source: "qrc:/assets/icons/buttons/PS4_Options.png"
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "Options Menu"
                color: "#ffffff"
                font.pixelSize: 17
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Options Menu Popup for User (Edit Name, Delete User)
    Rectangle {
        id: userOptionsDialog
        anchors.fill: parent
        color: "#90000d20"
        visible: root.isOptionsMenuOpen
        z: 200

        MouseArea {
            anchors.fill: parent
            onClicked: root.closeOptions()
        }

        Rectangle {
            anchors.centerIn: parent
            width: 360
            height: 210
            radius: 8
            color: "#0e1e36"
            border.color: "#ffffff"
            border.width: 2

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                Text {
                    text: "User Options"
                    color: "#ffffff"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#20ffffff"
                }

                // Option 0: Edit Name
                Rectangle {
                    width: parent.width
                    height: 44
                    radius: 4
                    readonly property bool isSelected: root.optionsSelectedIndex === 0
                    color: isSelected ? "#1a3866" : "transparent"
                    border.color: isSelected ? "#ffffff" : "transparent"
                    border.width: isSelected ? 2 : 0

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        spacing: 12
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "✎  Edit Name"
                            color: "#ffffff"
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.optionsSelectedIndex = 0;
                            root.triggerOptionsAction();
                        }
                    }
                }

                // Option 1: Delete User
                Rectangle {
                    width: parent.width
                    height: 44
                    radius: 4
                    readonly property bool isSelected: root.optionsSelectedIndex === 1
                    color: isSelected ? "#1a3866" : "transparent"
                    border.color: isSelected ? "#ffffff" : "transparent"
                    border.width: isSelected ? 2 : 0

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        spacing: 12
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "🗑  Delete User"
                            color: "#ffffff"
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.optionsSelectedIndex = 1;
                            root.triggerOptionsAction();
                        }
                    }
                }
            }
        }
    }

    // Actions
    function selectNext() {
        if (root.isOptionsMenuOpen) return;
        if (selectedIndex < usersList.length) {
            selectedIndex++;
            soundController.playTick();
        }
    }

    function selectPrevious() {
        if (root.isOptionsMenuOpen) return;
        if (selectedIndex > 0) {
            selectedIndex--;
            soundController.playTick();
        }
    }

    function selectUp() {
        if (root.isOptionsMenuOpen) {
            if (optionsSelectedIndex > 0) {
                optionsSelectedIndex--;
                soundController.playTick();
            }
        }
    }

    function selectDown() {
        if (root.isOptionsMenuOpen) {
            if (optionsSelectedIndex < 1) {
                optionsSelectedIndex++;
                soundController.playTick();
            }
        }
    }

    function openOptions() {
        if (selectedIndex > 0 && selectedIndex <= usersList.length) {
            optionsSelectedIndex = 0;
            isOptionsMenuOpen = true;
            soundController.playOptions();
        }
    }

    function closeOptions() {
        isOptionsMenuOpen = false;
        soundController.playBack();
    }

    function triggerOptionsAction() {
        if (optionsSelectedIndex === 0) {
            // Edit Name
            var uIdx = selectedIndex - 1;
            if (uIdx >= 0 && uIdx < usersList.length) {
                var userToEdit = usersList[uIdx];
                isOptionsMenuOpen = false;
                var kb = root.keyboardItem ? root.keyboardItem : virtualKeyboard;
                if (kb) {
                    kb.open("Edit User Name", userToEdit.name, function(newName) {
                        if (newName && newName.length > 0) {
                            var updatedUser = {
                                id: userToEdit.id,
                                name: newName,
                                avatar: userToEdit.avatar,
                                isCurrent: userToEdit.isCurrent
                            };
                            configManager.saveUser(updatedUser);
                        }
                    });
                }
            }
        } else if (optionsSelectedIndex === 1) {
            // Delete User
            if (usersList.length <= 1) {
                isOptionsMenuOpen = false;
                soundController.playBack();
                return;
            }
            var delIdx = selectedIndex - 1;
            if (delIdx >= 0 && delIdx < usersList.length) {
                var userToDelete = usersList[delIdx];
                isOptionsMenuOpen = false;
                configManager.deleteUser(userToDelete.id);
                soundController.playConfirm();
                if (selectedIndex > usersList.length) {
                    selectedIndex = usersList.length;
                }
            }
        }
    }

    function triggerCurrent() {
        if (root.isOptionsMenuOpen) {
            triggerOptionsAction();
            return;
        }

        if (selectedIndex === 0) {
            // New User (+) -> Open Virtual Keyboard to name new user
            soundController.playConfirm();
            var kbNew = root.keyboardItem ? root.keyboardItem : virtualKeyboard;
            if (kbNew) {
                kbNew.open("Enter Name for New User", "User " + (usersList.length + 1), function(newName) {
                    var finalName = newName ? newName : "User " + (usersList.length + 1);
                    var newUser = {
                        id: "user_" + Date.now(),
                        name: finalName,
                        avatar: "qrc:/assets/avatars/avatar_fox.svg",
                        isCurrent: true
                    };
                    configManager.saveUser(newUser);
                    userLoggedIn(newUser);
                });
            }
        } else {
            var targetIdx = selectedIndex - 1;
            if (targetIdx >= 0 && targetIdx < usersList.length) {
                var user = usersList[targetIdx];
                userLoggedIn(user);
            }
        }
    }

    function cancelCurrent() {
        if (root.isOptionsMenuOpen) {
            closeOptions();
        } else {
            returnToWelcome();
            soundController.playBack();
        }
    }
}
