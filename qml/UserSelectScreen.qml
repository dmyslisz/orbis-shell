import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent

    property int selectedIndex: 0
    property bool isCreatingUser: false
    property alias nameInputField: nameInput

    signal userLoggedIn(var user)
    signal returnToWelcome()

    readonly property var usersList: configManager.users

    Column {
        anchors.centerIn: parent
        spacing: 48

        Text {
            text: "Who is using this controller?"
            color: "#ffffff"
            font.pixelSize: 32
            font.weight: Font.Normal
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Horizontal Profiles Row
        Row {
            id: usersRow
            spacing: 36
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: usersList.length + 1 // +1 for "New User"

                Item {
                    required property int index
                    width: 170
                    height: 230

                    readonly property bool isNewUserCard: index === usersList.length
                    readonly property var userData: isNewUserCard ? null : usersList[index]
                    readonly property bool isSelected: root.selectedIndex === index

                    Column {
                        anchors.centerIn: parent
                        spacing: 16

                        // Avatar card with glowing selection border
                        Rectangle {
                            width: 130
                            height: 130
                            radius: 12
                            color: "#18325a"
                            border.color: isSelected ? "#ffffff" : "#4070a8"
                            border.width: isSelected ? 3.5 : 1.5
                            clip: true
                            scale: isSelected ? 1.08 : 1.0
                            anchors.horizontalCenter: parent.horizontalCenter

                            Behavior on scale {
                                NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
                            }

                            // Glow effect
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: -4
                                radius: 14
                                color: "transparent"
                                border.color: "#80d0ff"
                                border.width: 3
                                opacity: isSelected ? 0.6 : 0.0
                                visible: opacity > 0.01

                                Behavior on opacity {
                                    NumberAnimation { duration: 160 }
                                }
                            }

                            Image {
                                anchors.fill: parent
                                anchors.margins: 4
                                source: isNewUserCard ? "qrc:/assets/icons/ps_plus.svg" : (userData.avatar ? userData.avatar : "qrc:/assets/avatars/avatar_luchador.svg")
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        // Username text
                        Text {
                            text: isNewUserCard ? "New User" : (userData ? userData.name : "")
                            color: isSelected ? "#ffffff" : "#a0b8d8"
                            font.pixelSize: 18
                            font.weight: isSelected ? Font.Medium : Font.Normal
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        // Trophy level pill
                        Rectangle {
                            visible: !isNewUserCard && userData && userData.trophyLevel
                            width: 60
                            height: 22
                            radius: 11
                            color: "#204278"
                            border.color: "#5080c0"
                            border.width: 1
                            anchors.horizontalCenter: parent.horizontalCenter

                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                Text {
                                    text: "★"
                                    color: "#fbc02d"
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: userData && userData.trophyLevel ? userData.trophyLevel : "1"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Modal for New User name entry
    Rectangle {
        id: createModal
        anchors.fill: parent
        color: "#d0001030"
        visible: isCreatingUser
        z: 100

        Rectangle {
            anchors.centerIn: parent
            width: 480
            height: 260
            radius: 10
            color: "#162846"
            border.color: "#ffffff"
            border.width: 2

            Column {
                anchors.centerIn: parent
                spacing: 24
                width: parent.width - 64

                Text {
                    text: "Create New User"
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.weight: Font.Medium
                }

                TextField {
                    id: nameInput
                    width: parent.width
                    height: 48
                    placeholderText: "Enter user name..."
                    color: "#ffffff"
                    font.pixelSize: 18
                    background: Rectangle {
                        color: "#0a1628"
                        radius: 6
                        border.color: nameInput.activeFocus ? "#80d0ff" : "#305080"
                        border.width: 2
                    }
                }

                Row {
                    spacing: 16
                    anchors.right: parent.right

                    Button {
                        text: "Cancel"
                        onClicked: {
                            isCreatingUser = false;
                            soundController.playBack();
                        }
                    }

                    Button {
                        text: "Confirm"
                        highlighted: true
                        onClicked: confirmNewUser()
                    }
                }
            }
        }
    }

    // Actions
    function selectNext() {
        if (isCreatingUser) return;
        if (selectedIndex < usersList.length) {
            selectedIndex++;
            soundController.playTick();
        }
    }

    function selectPrevious() {
        if (isCreatingUser) return;
        if (selectedIndex > 0) {
            selectedIndex--;
            soundController.playTick();
        }
    }

    function triggerCurrent() {
        if (isCreatingUser) {
            confirmNewUser();
            return;
        }

        if (selectedIndex === usersList.length) {
            // New user
            isCreatingUser = true;
            nameInput.text = "";
            nameInput.forceActiveFocus();
            soundController.playConfirm();
        } else {
            var user = usersList[selectedIndex];
            soundController.playLogin();
            userLoggedIn(user);
        }
    }

    function cancelCurrent() {
        if (isCreatingUser) {
            isCreatingUser = false;
            soundController.playBack();
        } else {
            returnToWelcome();
            soundController.playBack();
        }
    }

    function confirmNewUser() {
        var name = nameInput.text.trim();
        if (name.length === 0) name = "Player " + (usersList.length + 1);

        var newUser = {
            id: "user_" + Date.now(),
            name: name,
            avatar: "qrc:/assets/avatars/avatar_fox.svg",
            trophyLevel: 1,
            trophies: { platinum: 0, gold: 0, silver: 0, bronze: 0 },
            plusMember: false,
            isCurrent: true
        };
        configManager.saveUser(newUser);
        isCreatingUser = false;
        soundController.playLogin();
        userLoggedIn(newUser);
    }
}
