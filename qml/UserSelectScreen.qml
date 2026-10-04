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

    // Centered Sub-header: Controller connected & Prompt (Photo 2)
    Column {
        id: headerPrompt
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 180
        spacing: 10

        Row {
            spacing: 12
            anchors.horizontalCenter: parent.horizontalCenter

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
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Who is using this controller?"
            color: "#ffffff"
            font.pixelSize: 24
            font.weight: Font.Normal
        }
    }

    // Centered Horizontal User Profiles Row (Photo 2)
    Row {
        id: usersRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 310
        spacing: 28

        // Card 0: "New User" Card (+)
        Item {
            width: 180
            height: 240

            readonly property bool isSelected: root.selectedIndex === 0 && !root.isOptionsMenuOpen

            // Card container
            Rectangle {
                anchors.fill: parent
                radius: 2
                color: "#0d47a1"
                scale: isSelected ? 1.05 : 1.0

                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                // Centered white '+' icon
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 46
                    text: "+"
                    color: "#ffffff"
                    font.pixelSize: 68
                    font.weight: Font.Light
                }

                // "New User" text inside card with crisp white font
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 24
                    text: "New User"
                    color: "#ffffff"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                }

                // White border overlay around ENTIRE card
                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: "transparent"
                    border.color: isSelected ? "#ffffff" : "#1a4686"
                    border.width: isSelected ? 3.5 : 1
                    z: 10
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
                width: 180
                height: 240

                readonly property bool isSelected: root.selectedIndex === cardIndex && !root.isOptionsMenuOpen

                // Card container
                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: "#0a2d64"
                    scale: isSelected ? 1.05 : 1.0

                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    // Avatar Image (top 180x180)
                    Item {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 180
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: modelData.avatar ? modelData.avatar : "qrc:/assets/avatars/avatar_luchador.svg"
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    // User name bar (bottom 180x60)
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 60
                        color: "#082352"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.name ? modelData.name : "User " + (index + 1)
                            color: "#ffffff"
                            font.pixelSize: 18
                            font.weight: Font.DemiBold
                        }
                    }

                    // White border overlay around ENTIRE card (on top of image and name bar)
                    Rectangle {
                        anchors.fill: parent
                        radius: 2
                        color: "transparent"
                        border.color: isSelected ? "#ffffff" : "#183a6e"
                        border.width: isSelected ? 3.5 : 1
                        z: 10
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

    // Bottom Action Prompts Bar with Universal Gamepad Badges
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 48
        spacing: 36

        Row {
            spacing: 10
            anchors.verticalCenter: parent.verticalCenter
            GamepadBadge {
                button: "A"
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
            spacing: 10
            anchors.verticalCenter: parent.verticalCenter
            GamepadBadge {
                button: "B"
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
            spacing: 10
            anchors.verticalCenter: parent.verticalCenter
            visible: root.selectedIndex > 0
            GamepadBadge {
                button: "OPTIONS"
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
