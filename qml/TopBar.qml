import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: parent.width
    height: 1080

    property bool isFocused: false
    property int selectedIndex: 1
    property string userName: "Player 1"
    property string userAvatar: "qrc:/assets/avatars/avatar_luchador.svg"
    property string trophyCount: "★ 18"

    signal iconSelected(int index, string name)
    signal returnToTiles()

    readonly property var icons: [
        { id: "plus", name: "PlayStation Plus", icon: "qrc:/assets/icons/ps_plus.svg" },
        { id: "notifications", name: "Notifications", icon: "qrc:/assets/icons/notifications.svg", badge: "2" },
        { id: "friends", name: "Friends", icon: "qrc:/assets/icons/friends.svg", badge: "4" },
        { id: "communities", name: "Communities", icon: "qrc:/assets/icons/communities.svg" },
        { id: "events", name: "Events", icon: "qrc:/assets/icons/events.svg" },
        { id: "messages", name: "Messages", icon: "qrc:/assets/icons/messages.svg" },
        { id: "party", name: "Party", icon: "qrc:/assets/icons/party.svg" },
        { id: "profile", name: "Profile", icon: "qrc:/assets/icons/profile.svg", isAvatar: true },
        { id: "trophies", name: "Trophies", icon: "qrc:/assets/icons/trophy.svg" },
        { id: "settings", name: "Settings", icon: "qrc:/assets/icons/settings.svg" },
        { id: "power", name: "Power", icon: "qrc:/assets/icons/power.svg" }
    ]

    // ==========================================
    // 1. TOP-RIGHT PERMANENT CLOCK, BATTERY & WI-FI
    // ==========================================
    Row {
        anchors.top: parent.top
        anchors.topMargin: 52
        anchors.right: parent.right
        anchors.rightMargin: 80
        spacing: 16
        height: 32

        // Network icon
        Image {
            width: 22
            height: 22
            source: "qrc:/assets/icons/WiFiHigh.png"
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter
            opacity: systemManager.isOnline ? 0.95 : 0.35
        }

        // Battery level
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            visible: systemManager.hasBattery

            Rectangle {
                width: 26
                height: 14
                radius: 2
                color: "transparent"
                border.color: "#ffffff"
                border.width: 1.5
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    x: 2
                    y: 2
                    width: Math.max(3, (parent.width - 4) * (systemManager.batteryPercent / 100.0))
                    height: parent.height - 4
                    color: systemManager.isCharging ? "#66bb6a" : (systemManager.batteryPercent < 20 ? "#ef5350" : "#ffffff")
                }
            }
            // Battery tip
            Rectangle {
                width: 2
                height: 6
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Clock Text
        Text {
            id: clockText
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
            font.pixelSize: 22
            font.weight: Font.Normal
            text: Qt.formatTime(new Date(), "h:mm AP")
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockText.text = Qt.formatTime(new Date(), "h:mm AP")
        }
    }

    // ==========================================
    // 2. COMPACT TOP STATUS BAR (When TileRow is active)
    // ==========================================
    Item {
        id: compactBar
        anchors.top: parent.top
        anchors.topMargin: 52
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.right: parent.right
        anchors.rightMargin: 240
        height: 36
        opacity: root.isFocused ? 0.0 : 1.0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 24

            Image {
                width: 22
                height: 22
                source: "qrc:/assets/icons/ps_plus.svg"
                fillMode: Image.PreserveAspectFit
            }

            Row {
                spacing: 6
                Image {
                    width: 22
                    height: 22
                    source: "qrc:/assets/icons/notifications.svg"
                    fillMode: Image.PreserveAspectFit
                }
                Rectangle {
                    width: 18
                    height: 18
                    radius: 9
                    color: "#006FCD"
                    border.color: "#ffffff"
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "2"
                        color: "#ffffff"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }
                }
            }

            Row {
                spacing: 6
                Image {
                    width: 22
                    height: 22
                    source: "qrc:/assets/icons/friends.svg"
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "4"
                    color: "#ffffff"
                    font.pixelSize: 14
                }
            }
        }

        // Right group: Profile + Trophies
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 24

            // User Profile
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // Online indicator
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: "#4caf50"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Square avatar
                Rectangle {
                    width: 24
                    height: 24
                    radius: 3
                    color: "#1a3560"
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.fill: parent
                        source: root.userAvatar
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.userName
                    color: "#ffffff"
                    font.pixelSize: 15
                }
            }

            // Trophies count
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Image {
                    width: 18
                    height: 18
                    source: "qrc:/assets/icons/trophy.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.trophyCount
                    color: "#fbc02d"
                    font.pixelSize: 15
                    font.weight: Font.Medium
                }
            }
        }
    }

    // ==========================================
    // 3. FULL EXPANDED TOP BAR (When TopBar is focused)
    // ==========================================
    Item {
        id: expandedBar
        anchors.top: parent.top
        anchors.topMargin: 110
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.right: parent.right
        anchors.rightMargin: 80
        height: 140
        opacity: root.isFocused ? 1.0 : 0.0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
        }

        // Horizontal Row of big icons
        Row {
            id: iconsRow
            anchors.top: parent.top
            anchors.left: parent.left
            spacing: 28

            Repeater {
                model: root.icons

                Item {
                    required property int index
                    required property var modelData
                    width: 54
                    height: 54

                    readonly property bool isSelected: root.isFocused && root.selectedIndex === index

                    Rectangle {
                        anchors.centerIn: parent
                        width: isSelected ? 58 : 46
                        height: isSelected ? 58 : 46
                        radius: 8
                        color: isSelected ? "#3060a0" : "transparent"
                        border.color: isSelected ? "#ffffff" : "transparent"
                        border.width: isSelected ? 2.5 : 0

                        Behavior on width { NumberAnimation { duration: 150 } }
                        Behavior on height { NumberAnimation { duration: 150 } }

                        Image {
                            anchors.centerIn: parent
                            width: isSelected ? 36 : 28
                            height: isSelected ? 36 : 28
                            source: modelData.isAvatar ? root.userAvatar : modelData.icon
                            fillMode: Image.PreserveAspectFit
                            opacity: isSelected ? 1.0 : 0.75
                        }

                        // Badge counter (if any)
                        Rectangle {
                            visible: modelData.badge !== undefined
                            anchors.top: parent.top
                            anchors.topMargin: -4
                            anchors.right: parent.right
                            anchors.rightMargin: -4
                            width: 18
                            height: 18
                            radius: 9
                            color: "#006FCD"
                            border.color: "#ffffff"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: modelData.badge !== undefined ? modelData.badge : ""
                                color: "#ffffff"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }
                        }
                    }
                }
            }
        }

        // Label beneath focused icon
        Text {
            anchors.top: iconsRow.bottom
            anchors.topMargin: 18
            anchors.left: parent.left
            x: root.selectedIndex * (54 + 28)
            text: root.icons[root.selectedIndex].name
            color: "#ffffff"
            font.pixelSize: 20
            font.weight: Font.Medium

            Behavior on x {
                NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
            }
        }
    }

    function selectNext() {
        if (selectedIndex < icons.length - 1) {
            selectedIndex++;
            return true;
        }
        return false;
    }

    function selectPrevious() {
        if (selectedIndex > 0) {
            selectedIndex--;
            return true;
        }
        return false;
    }

    function currentItem() {
        return icons[selectedIndex];
    }
}
