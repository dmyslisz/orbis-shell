import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: parent.width
    height: 380

    property bool isOpen: false
    property string text: ""
    property int selectedRow: 0
    property int selectedCol: 0

    signal textAccepted(string result)
    signal closeRequested()

    readonly property var keyboardRows: [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L", "."],
        ["Z", "X", "C", "V", "B", "N", "M", "_", "-", "/"]
    ]

    y: isOpen ? (parent.height - height) : parent.height
    visible: y < parent.height
    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

    Rectangle {
        anchors.fill: parent
        color: "#f008162e"
        border.color: "#30ffffff"
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 12

            Repeater {
                model: root.keyboardRows

                Row {
                    id: rowItem
                    required property int index
                    required property var modelData
                    readonly property int rowIndex: index
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater {
                        model: modelData

                        Item {
                            required property int index
                            required property var modelData
                            readonly property int colIndex: index
                            width: 68
                            height: 52

                            readonly property bool isSelected: root.isOpen && root.selectedRow === rowIndex && root.selectedCol === colIndex

                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: isSelected ? "#ffffff" : "#142646"
                                border.color: isSelected ? "#ffffff" : "#20ffffff"
                                border.width: isSelected ? 2.5 : 1

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: isSelected ? "#0a1d3d" : "#ffffff"
                                    font.pixelSize: 20
                                    font.weight: isSelected ? Font.Bold : Font.Medium
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    root.selectedRow = rowIndex;
                                    root.selectedCol = colIndex;
                                    root.text += modelData;
                                    soundController.playKeypress();
                                }
                            }
                        }
                    }
                }
            }

            // Bottom Actions Row: Space, Backspace, Done
            Row {
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter

                // Space
                Rectangle {
                    width: 320
                    height: 48
                    radius: 4
                    color: (root.selectedRow === 4 && root.selectedCol === 0) ? "#ffffff" : "#142646"
                    border.color: (root.selectedRow === 4 && root.selectedCol === 0) ? "#ffffff" : "#20ffffff"
                    border.width: (root.selectedRow === 4 && root.selectedCol === 0) ? 2.5 : 1

                    Text {
                        anchors.centerIn: parent
                        text: "Space"
                        color: (root.selectedRow === 4 && root.selectedCol === 0) ? "#0a1d3d" : "#ffffff"
                        font.pixelSize: 18
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedRow = 4;
                            root.selectedCol = 0;
                            root.text += " ";
                            soundController.playKeypress();
                        }
                    }
                }

                // Backspace
                Rectangle {
                    width: 140
                    height: 48
                    radius: 4
                    color: (root.selectedRow === 4 && root.selectedCol === 1) ? "#ffffff" : "#142646"
                    border.color: (root.selectedRow === 4 && root.selectedCol === 1) ? "#ffffff" : "#20ffffff"
                    border.width: (root.selectedRow === 4 && root.selectedCol === 1) ? 2.5 : 1

                    Text {
                        anchors.centerIn: parent
                        text: "⌫ Backspace"
                        color: (root.selectedRow === 4 && root.selectedCol === 1) ? "#0a1d3d" : "#ffffff"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedRow = 4;
                            root.selectedCol = 1;
                            if (root.text.length > 0) {
                                root.text = root.text.slice(0, -1);
                                soundController.playBackspace();
                            } else {
                                soundController.playKeyError();
                            }
                        }
                    }
                }

                // Enter / Done
                Rectangle {
                    width: 140
                    height: 48
                    radius: 4
                    color: (root.selectedRow === 4 && root.selectedCol === 2) ? "#ffffff" : "#006FCD"
                    border.color: "#ffffff"
                    border.width: 1.5

                    Text {
                        anchors.centerIn: parent
                        text: "Enter ⏎"
                        color: (root.selectedRow === 4 && root.selectedCol === 2) ? "#0a1d3d" : "#ffffff"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedRow = 4;
                            root.selectedCol = 2;
                            soundController.playConfirm();
                            root.textAccepted(root.text);
                            root.closeRequested();
                        }
                    }
                }
            }
        }
    }

    function selectPrevious() {
        if (selectedRow < 4) {
            if (selectedCol > 0) {
                selectedCol--;
                soundController.playCursorMove();
                return true;
            }
        } else {
            if (selectedCol > 0) {
                selectedCol--;
                soundController.playCursorMove();
                return true;
            }
        }
        return false;
    }

    function selectNext() {
        if (selectedRow < 4) {
            if (selectedCol < 9) {
                selectedCol++;
                soundController.playCursorMove();
                return true;
            }
        } else {
            if (selectedCol < 2) {
                selectedCol++;
                soundController.playCursorMove();
                return true;
            }
        }
        return false;
    }

    function selectUp() {
        if (selectedRow > 0) {
            selectedRow--;
            if (selectedRow === 3 && selectedCol > 9) selectedCol = 9;
            soundController.playCursorMove();
            return true;
        }
        return false;
    }

    function selectDown() {
        if (selectedRow < 4) {
            selectedRow++;
            if (selectedRow === 4) {
                if (selectedCol < 5) selectedCol = 0;
                else if (selectedCol < 8) selectedCol = 1;
                else selectedCol = 2;
            }
            soundController.playCursorMove();
            return true;
        }
        return false;
    }

    function triggerCurrent() {
        if (selectedRow < 4) {
            var char = keyboardRows[selectedRow][selectedCol];
            root.text += char;
            soundController.playKeypress();
        } else {
            if (selectedCol === 0) {
                root.text += " ";
                soundController.playKeypress();
            } else if (selectedCol === 1) {
                if (root.text.length > 0) {
                    root.text = root.text.slice(0, -1);
                    soundController.playBackspace();
                } else {
                    soundController.playKeyError();
                }
            } else if (selectedCol === 2) {
                soundController.playConfirm();
                root.textAccepted(root.text);
                root.closeRequested();
            }
        }
    }
}
