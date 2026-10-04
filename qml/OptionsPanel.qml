import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: parent.width
    height: 1080

    property bool isOpen: false
    property var currentAppData: null
    property int selectedIndex: 0
    property bool showingInfoDialog: false

    signal actionTriggered(string actionId, var appData)
    signal closeRequested()

    readonly property var optionsList: [
        { id: "start", label: (processLauncher.isAppRunning && processLauncher.currentAppName === (root.currentAppData ? root.currentAppData.name : "")) ? "Resume" : "Start" },
        { id: "close", label: "Close Application" },
        { id: "update", label: "Check for Update" },
        { id: "info", label: "Information" },
        { id: "delete", label: "Delete" }
    ]

    // Semi-transparent backdrop
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

    // Slide-out panel from the right edge
    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 440
        color: "#ea06142a"
        border.color: "#25ffffff"
        border.width: 1

        x: root.isOpen ? (parent.width - width) : parent.width

        Behavior on x {
            NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 40
            anchors.topMargin: 80
            spacing: 28

            // Header title
            Text {
                text: "Options"
                color: "#ffffff"
                font.pixelSize: 28
                font.weight: Font.DemiBold
            }

            // Target app thumbnail & title
            Row {
                spacing: 16
                visible: root.currentAppData !== null

                Rectangle {
                    width: 48
                    height: 48
                    radius: 4
                    color: "#0a1d3d"
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: (root.currentAppData && root.currentAppData.icon) ? root.currentAppData.icon : ""
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: (root.currentAppData && root.currentAppData.name) ? root.currentAppData.name : ""
                    color: "#a0c0e8"
                    font.pixelSize: 18
                    elide: Text.ElideRight
                    width: 280
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#20ffffff"
            }

            // Options list
            Column {
                width: parent.width
                spacing: 8

                Repeater {
                    model: root.optionsList

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

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                color: isSelected ? "#0a1d3d" : "#ffffff"
                                font.pixelSize: 18
                                font.weight: isSelected ? Font.Medium : Font.Normal
                            }
                        }
                    }
                }
            }
        }
    }

    // Information Modal Dialog
    Rectangle {
        id: infoDialog
        anchors.fill: parent
        color: "#c0000000"
        visible: root.showingInfoDialog
        z: 200

        Rectangle {
            anchors.centerIn: parent
            width: 560
            height: 420
            radius: 8
            color: "#0d203f"
            border.color: "#ffffff"
            border.width: 2

            Column {
                anchors.fill: parent
                anchors.margins: 36
                spacing: 24

                Text {
                    text: "Information"
                    color: "#ffffff"
                    font.pixelSize: 26
                    font.weight: Font.DemiBold
                }

                Grid {
                    columns: 2
                    rowSpacing: 16
                    columnSpacing: 24
                    width: parent.width

                    Text { text: "Title:"; color: "#a0b8d8"; font.pixelSize: 16; width: 140 }
                    Text { text: (root.currentAppData && root.currentAppData.name) ? root.currentAppData.name : "-"; color: "#ffffff"; font.pixelSize: 16 }

                    Text { text: "Platform:"; color: "#a0b8d8"; font.pixelSize: 16 }
                    Text { text: (root.currentAppData && root.currentAppData.isSteam) ? "Steam (Proton/Native)" : "Fedora Linux Desktop"; color: "#ffffff"; font.pixelSize: 16 }

                    Text { text: "Executable:"; color: "#a0b8d8"; font.pixelSize: 16 }
                    Text { text: (root.currentAppData && root.currentAppData.exec) ? root.currentAppData.exec : "-"; color: "#ffffff"; font.pixelSize: 15; elide: Text.ElideRight; width: 320 }

                    Text { text: "Category:"; color: "#a0b8d8"; font.pixelSize: 16 }
                    Text { text: (root.currentAppData && root.currentAppData.category) ? root.currentAppData.category : "Applications"; color: "#ffffff"; font.pixelSize: 16 }

                    Text { text: "Version:"; color: "#a0b8d8"; font.pixelSize: 16 }
                    Text { text: "1.0.0 (Linux x86_64)"; color: "#ffffff"; font.pixelSize: 16 }
                }

                Item { width: 1; height: 10 }

                Button {
                    text: "OK (Back)"
                    anchors.right: parent.right
                    highlighted: true
                    onClicked: {
                        root.showingInfoDialog = false;
                        soundController.playBack();
                    }
                }
            }
        }
    }

    function selectPrevious() {
        if (root.showingInfoDialog) return false;
        if (selectedIndex > 0) {
            selectedIndex--;
            return true;
        }
        return false;
    }

    function selectNext() {
        if (root.showingInfoDialog) return false;
        if (selectedIndex < optionsList.length - 1) {
            selectedIndex++;
            return true;
        }
        return false;
    }

    function triggerCurrent() {
        if (root.showingInfoDialog) {
            root.showingInfoDialog = false;
            soundController.playBack();
            return;
        }

        var opt = optionsList[selectedIndex];
        if (opt.id === "info") {
            root.showingInfoDialog = true;
            soundController.playConfirm();
        } else {
            actionTriggered(opt.id, root.currentAppData);
        }
    }
}
