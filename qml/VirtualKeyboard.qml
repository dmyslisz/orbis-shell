import QtQuick

Item {
    id: root
    anchors.fill: parent
    visible: isOpen
    z: 999

    property bool isOpen: false
    property string title: "Enter Text"
    property string text: ""
    property var callback: null

    property bool isShift: false
    property bool isSymbols: false

    // Grid coordinates
    // Row 0: numbers (0..9)
    // Row 1: QWERTY 1 (0..9)
    // Row 2: QWERTY 2 (0..9)
    // Row 3: QWERTY 3 (0..9)
    // Row 4: bottom actions: 0: Shift, 1: Symbols, 2: Space, 3: Backspace, 4: Done
    property int selectedRow: 1
    property int selectedCol: 3 // Start focused around 'r' like Photo 4!

    signal textAccepted(string result)
    signal closeRequested()

    readonly property var lowerRows: [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l", "'"],
        ["z", "x", "c", "v", "b", "n", "m", ",", ".", "?"]
    ]

    readonly property var upperRows: [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L", "\""],
        ["Z", "X", "C", "V", "B", "N", "M", "!", ";", ":"]
    ]

    readonly property var symbolRows: [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["~", "`", "@", "#", "$", "%", "^", "&", "*", "("],
        [")", "-", "_", "=", "+", "[", "]", "{", "}", "\\"],
        ["|", ";", ":", "\"", "'", "<", ">", "/", "?", "£"]
    ]

    readonly property var activeRows: isSymbols ? symbolRows : (isShift ? upperRows : lowerRows)

    // Suggestion candidates based on current text
    readonly property var suggestions: {
        if (!text || text.length === 0) return ["User", "Player", "Game", "Admin"];
        var trimmed = text.trim();
        var cap = trimmed.charAt(0).toUpperCase() + trimmed.slice(1);
        return [trimmed, cap, trimmed + "1", trimmed + "_", trimmed + "ing", trimmed + "er"];
    }

    // Dim background scrim
    Rectangle {
        anchors.fill: parent
        color: "#90040c1a"
        opacity: root.isOpen ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180 } }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Input Text Bar (Docked above keyboard or center)
    Rectangle {
        id: inputBox
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: keyboardPanel.top
        anchors.bottomMargin: 24
        width: 720
        height: 56
        radius: 6
        color: "#0a182c"
        border.color: "#006FCD"
        border.width: 2

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Text {
                text: root.text
                color: "#ffffff"
                font.pixelSize: 22
                font.weight: Font.Normal
                anchors.verticalCenter: parent.verticalCenter
            }

            // Blinking cursor
            Rectangle {
                width: 2.5
                height: 24
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.0; duration: 450 }
                    NumberAnimation { to: 0.0; duration: 450 }
                }
            }
        }

        // Title prompt on top of input box
        Text {
            anchors.left: parent.left
            anchors.bottom: parent.top
            anchors.bottomMargin: 8
            text: root.title
            color: "#80b0e8"
            font.pixelSize: 16
            font.weight: Font.Medium
        }
    }

    // Authentic PS4 Keyboard Window (Photo 4)
    Rectangle {
        id: keyboardPanel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 48
        width: 720
        height: 350
        radius: 8
        color: "#0d1b2e"
        border.color: "#28456c"
        border.width: 1.5
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            // 1. Prediction / Suggestion Bar (Photo 4)
            Rectangle {
                width: parent.width
                height: 38
                color: "#081220"
                radius: 4

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 14

                    Repeater {
                        model: root.suggestions
                        Item {
                            required property int index
                            required property string modelData
                            width: candidateText.implicitWidth + 16
                            height: 28

                            Rectangle {
                                anchors.fill: parent
                                radius: 3
                                color: "#142642"
                                border.color: "#25426b"
                                border.width: 1

                                Text {
                                    id: candidateText
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: "#b0d0f8"
                                    font.pixelSize: 13
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        root.text = modelData;
                                        soundController.playKeypress();
                                    }
                                }
                            }
                        }
                    }
                }

                // Close 'X' button on far right of predictive bar
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    width: 28
                    height: 28
                    radius: 4
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: "#a0c0e8"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.close()
                    }
                }
            }

            // 2. Character Rows (4 Rows: Numbers + QWERTY)
            Repeater {
                model: root.activeRows

                Row {
                    id: keyRowItem
                    required property int index
                    required property var modelData
                    readonly property int rowIndex: index
                    spacing: 6
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater {
                        model: modelData

                        Item {
                            required property int index
                            required property string modelData
                            readonly property int colIndex: index
                            width: 63
                            height: 44

                            readonly property bool isKeyFocused: root.isOpen && root.selectedRow === rowIndex && root.selectedCol === colIndex

                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: isKeyFocused ? "#1a3458" : "#122036"
                                border.color: isKeyFocused ? "#ffffff" : "#204060"
                                border.width: isKeyFocused ? 2.5 : 1

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: "#ffffff"
                                    font.pixelSize: 19
                                    font.weight: isKeyFocused ? Font.Bold : Font.Normal
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

            // 3. Bottom Action Row (Shift, Symbols, Space, Backspace, Done)
            Row {
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter

                // Shift
                Rectangle {
                    width: 78
                    height: 44
                    radius: 4
                    readonly property bool isBtnFocused: root.isOpen && root.selectedRow === 4 && root.selectedCol === 0
                    color: isBtnFocused ? "#1a3458" : (root.isShift ? "#006FCD" : "#122036")
                    border.color: isBtnFocused ? "#ffffff" : "#204060"
                    border.width: isBtnFocused ? 2.5 : 1

                    Text {
                        anchors.centerIn: parent
                        text: "⇧ Shift"
                        color: "#ffffff"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedRow = 4;
                            root.selectedCol = 0;
                            root.toggleShift();
                        }
                    }
                }

                // Symbols
                Rectangle {
                    width: 78
                    height: 44
                    radius: 4
                    readonly property bool isBtnFocused: root.isOpen && root.selectedRow === 4 && root.selectedCol === 1
                    color: isBtnFocused ? "#1a3458" : (root.isSymbols ? "#006FCD" : "#122036")
                    border.color: isBtnFocused ? "#ffffff" : "#204060"
                    border.width: isBtnFocused ? 2.5 : 1

                    Text {
                        anchors.centerIn: parent
                        text: "@#:"
                        color: "#ffffff"
                        font.pixelSize: 15
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedRow = 4;
                            root.selectedCol = 1;
                            root.isSymbols = !root.isSymbols;
                            soundController.playTick();
                        }
                    }
                }

                // Space
                Rectangle {
                    width: 250
                    height: 44
                    radius: 4
                    readonly property bool isBtnFocused: root.isOpen && root.selectedRow === 4 && root.selectedCol === 2
                    color: isBtnFocused ? "#1a3458" : "#122036"
                    border.color: isBtnFocused ? "#ffffff" : "#204060"
                    border.width: isBtnFocused ? 2.5 : 1

                    Text {
                        anchors.centerIn: parent
                        text: "Space"
                        color: "#ffffff"
                        font.pixelSize: 15
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedRow = 4;
                            root.selectedCol = 2;
                            root.text += " ";
                            soundController.playKeypress();
                        }
                    }
                }

                // Backspace
                Rectangle {
                    width: 104
                    height: 44
                    radius: 4
                    readonly property bool isBtnFocused: root.isOpen && root.selectedRow === 4 && root.selectedCol === 3
                    color: isBtnFocused ? "#1a3458" : "#122036"
                    border.color: isBtnFocused ? "#ffffff" : "#204060"
                    border.width: isBtnFocused ? 2.5 : 1

                    Text {
                        anchors.centerIn: parent
                        text: "⌫ Delete"
                        color: "#ffffff"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedRow = 4;
                            root.selectedCol = 3;
                            root.backspace();
                        }
                    }
                }

                // Done (Authentic PS4 Blue button)
                Rectangle {
                    width: 140
                    height: 44
                    radius: 4
                    readonly property bool isBtnFocused: root.isOpen && root.selectedRow === 4 && root.selectedCol === 4
                    color: isBtnFocused ? "#0088ff" : "#006FCD"
                    border.color: isBtnFocused ? "#ffffff" : "#40a0ff"
                    border.width: isBtnFocused ? 2.5 : 1

                    Text {
                        anchors.centerIn: parent
                        text: "Done ⏎"
                        color: "#ffffff"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedRow = 4;
                            root.selectedCol = 4;
                            root.confirm();
                        }
                    }
                }
            }
        }
    }

    // Keyboard navigation functions
    function selectUp() {
        if (!isOpen) return false;
        if (selectedRow > 0) {
            selectedRow--;
            if (selectedRow < 4 && selectedCol > 9) selectedCol = 9;
            soundController.playCursorMove();
            return true;
        }
        return false;
    }

    function selectDown() {
        if (!isOpen) return false;
        if (selectedRow < 4) {
            selectedRow++;
            if (selectedRow === 4) {
                // Map columns to bottom row items
                if (selectedCol <= 1) selectedCol = 0;
                else if (selectedCol <= 3) selectedCol = 1;
                else if (selectedCol <= 6) selectedCol = 2;
                else if (selectedCol <= 8) selectedCol = 3;
                else selectedCol = 4;
            }
            soundController.playCursorMove();
            return true;
        }
        return false;
    }

    function selectLeft() {
        if (!isOpen) return false;
        if (selectedCol > 0) {
            selectedCol--;
            soundController.playCursorMove();
            return true;
        }
        return false;
    }

    function selectRight() {
        if (!isOpen) return false;
        var maxCol = (selectedRow === 4) ? 4 : 9;
        if (selectedCol < maxCol) {
            selectedCol++;
            soundController.playCursorMove();
            return true;
        }
        return false;
    }

    function triggerCurrent() {
        if (!isOpen) return;
        if (selectedRow < 4) {
            var ch = activeRows[selectedRow][selectedCol];
            root.text += ch;
            soundController.playKeypress();
        } else {
            if (selectedCol === 0) {
                toggleShift();
            } else if (selectedCol === 1) {
                isSymbols = !isSymbols;
                soundController.playTick();
            } else if (selectedCol === 2) {
                root.text += " ";
                soundController.playKeypress();
            } else if (selectedCol === 3) {
                backspace();
            } else if (selectedCol === 4) {
                confirm();
            }
        }
    }

    function backspace() {
        if (!isOpen) return;
        if (root.text.length > 0) {
            root.text = root.text.slice(0, -1);
            soundController.playBackspace();
        } else {
            soundController.playKeyError();
        }
    }

    function toggleShift() {
        isShift = !isShift;
        soundController.playTick();
    }

    function confirm() {
        if (!isOpen) return;
        soundController.playConfirm();
        var result = root.text.trim();
        root.textAccepted(result);
        if (typeof callback === "function") {
            callback(result);
        }
        close();
    }

    function open(promptTitle, initialText, cb) {
        root.title = promptTitle ? promptTitle : "Enter Text";
        root.text = initialText ? initialText : "";
        root.callback = cb;
        root.isOpen = true;
        root.selectedRow = 1;
        root.selectedCol = 3; // 'r' key
        root.forceActiveFocus();
    }

    function close() {
        root.isOpen = false;
        root.closeRequested();
    }

    // Direct physical keyboard handling
    Keys.onPressed: function(event) {
        if (!isOpen) return;

        if (event.key === Qt.Key_Escape) {
            close();
            soundController.playBack();
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            confirm();
            event.accepted = true;
        } else if (event.key === Qt.Key_Backspace) {
            backspace();
            event.accepted = true;
        } else if (event.key === Qt.Key_Left) {
            selectLeft();
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            selectRight();
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            selectUp();
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            selectDown();
            event.accepted = true;
        } else if (event.key === Qt.Key_Space) {
            root.text += " ";
            soundController.playKeypress();
            event.accepted = true;
        } else if (event.text && event.text.length > 0 && event.text.charCodeAt(0) >= 32) {
            root.text += event.text;
            soundController.playKeypress();
            event.accepted = true;
        }
    }
}
