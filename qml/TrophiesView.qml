import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent

    property bool isOpen: false
    property int selectedIndex: 0

    signal closeRequested()

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
                    source: "qrc:/assets/icons/trophy.svg"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Trophies"
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

                GamepadBadge {
                    button: "B"
                    size: 20
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

        // User Trophies Summary Card
        Rectangle {
            id: summaryCard
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 60
            height: 90
            radius: 8
            color: "#0d203e"
            border.color: "#25ffffff"
            border.width: 1

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 28
                anchors.verticalCenter: parent.verticalCenter
                spacing: 20

                Rectangle {
                    width: 52
                    height: 52
                    radius: 8
                    color: "#18325a"
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.fill: parent
                        source: "qrc:/assets/avatars/avatar_luchador.svg"
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        text: configManager.activeUser ? configManager.activeUser : "Player 1"
                        color: "#ffffff"
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                    }

                    Row {
                        spacing: 8
                        Text { text: "Trophy Level 18"; color: "#fbc02d"; font.pixelSize: 15; font.weight: Font.Medium }
                    }
                }
            }

            // Trophies Badges Row
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 40
                anchors.verticalCenter: parent.verticalCenter
                spacing: 36

                // Platinum
                Row {
                    spacing: 10
                    Image { width: 28; height: 28; source: "qrc:/assets/icons/trophy_platinum.svg"; fillMode: Image.PreserveAspectFit }
                    Text { text: "4"; color: "#ffffff"; font.pixelSize: 18; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter }
                }

                // Gold
                Row {
                    spacing: 10
                    Image { width: 28; height: 28; source: "qrc:/assets/icons/trophy_gold.svg"; fillMode: Image.PreserveAspectFit }
                    Text { text: "22"; color: "#ffffff"; font.pixelSize: 18; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter }
                }

                // Silver
                Row {
                    spacing: 10
                    Image { width: 28; height: 28; source: "qrc:/assets/icons/trophy_silver.svg"; fillMode: Image.PreserveAspectFit }
                    Text { text: "58"; color: "#ffffff"; font.pixelSize: 18; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter }
                }

                // Bronze
                Row {
                    spacing: 10
                    Image { width: 28; height: 28; source: "qrc:/assets/icons/trophy_bronze.svg"; fillMode: Image.PreserveAspectFit }
                    Text { text: "210"; color: "#ffffff"; font.pixelSize: 18; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter }
                }
            }
        }

        // Trophies List
        ListView {
            id: trophiesList
            anchors.top: summaryCard.bottom
            anchors.topMargin: 24
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 60
            clip: true
            spacing: 8
            model: configManager.trophies

            delegate: Item {
                required property int index
                required property var modelData
                width: trophiesList.width
                height: 76

                readonly property bool isSelected: root.selectedIndex === index

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: isSelected ? "#ffffff" : "#0d1e38"
                    border.color: isSelected ? "#ffffff" : "#18ffffff"
                    border.width: isSelected ? 2 : 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 20

                        // Trophy Cup Icon
                        Image {
                            width: 40
                            height: 40
                            source: {
                                if (modelData.type === "platinum") return "qrc:/assets/icons/trophy_platinum.svg";
                                if (modelData.type === "gold") return "qrc:/assets/icons/trophy_gold.svg";
                                if (modelData.type === "silver") return "qrc:/assets/icons/trophy_silver.svg";
                                return "qrc:/assets/icons/trophy_bronze.svg";
                            }
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: modelData.unlocked ? 1.0 : 0.35
                        }

                        // Title & Description
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4
                            width: parent.width - 320

                            Text {
                                text: modelData.title
                                color: isSelected ? "#0a1d3d" : "#ffffff"
                                font.pixelSize: 18
                                font.weight: isSelected ? Font.DemiBold : Font.Normal
                            }

                            Text {
                                text: modelData.description
                                color: isSelected ? "#2a4d7d" : "#90a8c8"
                                font.pixelSize: 14
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }

                        // Unlock date / Rarity
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            spacing: 4

                            Text {
                                anchors.right: parent.right
                                text: modelData.unlocked ? modelData.unlockedDate : "Locked"
                                color: isSelected ? "#0a1d3d" : (modelData.unlocked ? "#ffffff" : "#6080a0")
                                font.pixelSize: 14
                            }

                            Text {
                                anchors.right: parent.right
                                text: modelData.rarity ? modelData.rarity : "Ultra Rare"
                                color: isSelected ? "#2a4d7d" : "#7090b0"
                                font.pixelSize: 13
                            }
                        }
                    }
                }
            }
        }
    }

    function selectPrevious() {
        if (selectedIndex > 0) {
            selectedIndex--;
            trophiesList.positionViewAtIndex(selectedIndex, ListView.Contain);
            return true;
        }
        return false;
    }

    function selectNext() {
        if (selectedIndex < configManager.trophies.length - 1) {
            selectedIndex++;
            trophiesList.positionViewAtIndex(selectedIndex, ListView.Contain);
            return true;
        }
        return false;
    }
}
