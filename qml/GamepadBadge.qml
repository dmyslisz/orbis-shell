import QtQuick

Item {
    id: root

    property string button: "A"
    property real size: 22
    property color badgeColor: "#ffffff"
    property color textColor: "#ffffff"
    property color bgColor: "#30ffffff"

    readonly property bool isMenuButton: button === "OPTIONS" || button === "MENU" || button === "START"

    width: isMenuButton ? (size * 1.35) : size
    height: size

    Rectangle {
        anchors.fill: parent
        radius: root.isMenuButton ? 4 : (root.size / 2)
        color: root.bgColor
        border.color: root.badgeColor
        border.width: 1.5

        Text {
            anchors.centerIn: parent
            text: root.isMenuButton ? "☰" : root.button
            color: root.textColor
            font.pixelSize: root.isMenuButton ? (root.size * 0.6) : (root.size * 0.56)
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
