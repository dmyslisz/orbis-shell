import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: parent.width
    height: 480

    property var appsModel: []
    property int currentIndex: 1
    property bool isRowFocused: true
    property bool isDeckActive: false

    readonly property real baseTileWidth: 204
    readonly property real tileSpacing: 18
    readonly property real activeScreenX: 200

    signal itemFocused(int index, var appData)

    // Vertical position:
    // When isRowFocused: 210
    // When TopBar is focused: 820 (slides down)
    // When Overview Deck is active: -180 (slides up)
    y: isDeckActive ? -180 : (isRowFocused ? 210 : 820)
    opacity: isDeckActive ? 0.3 : 1.0

    Behavior on y {
        NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
    }
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    Item {
        id: container
        height: root.height

        readonly property real targetX: {
            var itemX = currentIndex * (root.baseTileWidth + root.tileSpacing);
            return root.activeScreenX - itemX;
        }

        property real animatedX: targetX
        Behavior on animatedX {
            NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
        }

        x: animatedX

        Repeater {
            id: tileRepeater
            model: root.appsModel

            TileItem {
                itemIndex: index
                focusedIndex: root.currentIndex
                isRowFocused: root.isRowFocused && !root.isDeckActive
                appData: modelData
            }
        }
    }

    function selectPrevious() {
        if (currentIndex > 0) {
            currentIndex--;
            notifyFocus();
            return true;
        }
        return false;
    }

    function selectNext() {
        if (currentIndex < appsModel.length - 1) {
            currentIndex++;
            notifyFocus();
            return true;
        }
        return false;
    }

    function currentItem() {
        if (currentIndex >= 0 && currentIndex < appsModel.length) {
            return appsModel[currentIndex];
        }
        return null;
    }

    function notifyFocus() {
        var item = currentItem();
        if (item) {
            itemFocused(currentIndex, item);
        }
    }

    onAppsModelChanged: {
        if (currentIndex >= appsModel.length) {
            currentIndex = Math.max(0, appsModel.length - 1);
        }
        notifyFocus();
    }
}
