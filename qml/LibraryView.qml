import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent

    property bool isOpen: false
    property int selectedCategoryIndex: 0
    property int selectedGridIndex: 0
    property bool isGridFocused: true
    property string searchQuery: ""

    signal appSelected(var appData)
    signal closeRequested()

    readonly property var libraryCategories: [
        { id: "all", name: "All" },
        { id: "games", name: "Games" },
        { id: "apps", name: "Applications" },
        { id: "media", name: "Media" },
        { id: "system", name: "System" }
    ]

    // Filtered list of applications
    readonly property var filteredApps: {
        var baseList = [];
        // Combine config apps and dynamically scanned apps
        for (var i = 0; i < configManager.apps.length; ++i) {
            var item = configManager.apps[i];
            if (item.id !== "library") { // don't show library itself inside library
                baseList.push(item);
            }
        }
        for (var j = 0; j < appScanner.installedApps.length; ++j) {
            baseList.push(appScanner.installedApps[j]);
        }

        var catId = libraryCategories[selectedCategoryIndex].id;
        var query = searchQuery.trim().toLowerCase();

        return baseList.filter(function(app) {
            // Category filter
            if (catId === "games") {
                if (!app.isSteam && app.category !== "Games" && app.id !== "retroarch") return false;
            } else if (catId === "apps") {
                if (app.isSteam || app.category === "Games") return false;
            } else if (catId === "media") {
                if (app.category !== "Media" && app.id !== "gallery" && app.id !== "tv_video") return false;
            } else if (catId === "system") {
                if (app.category !== "System" && app.id !== "terminal" && app.id !== "settings") return false;
            }

            // Search query filter
            if (query.length > 0) {
                var appName = (app.name || "").toLowerCase();
                var appComm = (app.comment || "").toLowerCase();
                return appName.indexOf(query) !== -1 || appComm.indexOf(query) !== -1;
            }
            return true;
        });
    }

    visible: isOpen
    opacity: isOpen ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    Rectangle {
        anchors.fill: parent
        color: "#08142a"

        // Top Header & Search Bar
        Item {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 110
            anchors.margins: 60

            Row {
                spacing: 20
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    width: 38
                    height: 38
                    source: "qrc:/assets/icons/library.svg"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Library"
                    color: "#ffffff"
                    font.pixelSize: 32
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Search Bar
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: 440
                height: 44
                radius: 6
                color: "#102342"
                border.color: "#305580"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Image {
                        width: 22
                        height: 22
                        source: "qrc:/assets/icons/search.svg"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: searchInput
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 40
                        placeholderText: "Search games and applications..."
                        color: "#ffffff"
                        font.pixelSize: 16
                        background: null
                        onTextChanged: root.searchQuery = text
                    }
                }
            }

            // Back hint
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Image {
                    width: 22
                    height: 22
                    source: "qrc:/assets/icons/buttons/PS4_Circle.png"
                    fillMode: Image.PreserveAspectFit
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

        Rectangle {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#20ffffff"
        }

        // Main Area: Left Category Selector + Right Apps Grid
        Item {
            anchors.top: header.bottom
            anchors.topMargin: 20
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 60

            // Left Category Navigation
            ListView {
                id: catList
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: 240
                spacing: 8
                model: root.libraryCategories

                delegate: Item {
                    required property int index
                    required property var modelData
                    width: catList.width
                    height: 52

                    readonly property bool isSelected: !root.isGridFocused && root.selectedCategoryIndex === index
                    readonly property bool isCurrentCat: root.selectedCategoryIndex === index

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: isSelected ? "#ffffff" : (isCurrentCat ? "#204578" : "transparent")

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.name
                            color: isSelected ? "#0a1d3d" : "#ffffff"
                            font.pixelSize: 19
                            font.weight: isCurrentCat ? Font.DemiBold : Font.Normal
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedCategoryIndex = index;
                            root.selectedGridIndex = 0;
                            soundController.playTick();
                        }
                    }
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: catList.right
                anchors.leftMargin: 30
                width: 1
                color: "#20ffffff"
            }

            // Right Apps GridView
            GridView {
                id: appsGrid
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: catList.right
                anchors.leftMargin: 50
                anchors.right: parent.right
                clip: true
                cellWidth: 260
                cellHeight: 220
                model: root.filteredApps

                delegate: Item {
                    required property int index
                    required property var modelData
                    width: appsGrid.cellWidth
                    height: appsGrid.cellHeight

                    readonly property bool isSelected: root.isGridFocused && root.selectedGridIndex === index

                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        horizontalAlignment: Text.AlignHCenter

                        Rectangle {
                            width: 180
                            height: 140
                            radius: 4
                            color: "#102344"
                            border.color: isSelected ? "#ffffff" : "#25ffffff"
                            border.width: isSelected ? 3.5 : 1
                            scale: isSelected ? 1.06 : 1.0
                            clip: true

                            Behavior on scale { NumberAnimation { duration: 150 } }

                            Image {
                                anchors.fill: parent
                                source: modelData.icon ? modelData.icon : "qrc:/assets/icons/gamepad.svg"
                                fillMode: Image.PreserveAspectCrop
                            }
                        }

                        Text {
                            text: modelData.name
                            color: isSelected ? "#ffffff" : "#b0c8e8"
                            font.pixelSize: 16
                            font.weight: isSelected ? Font.DemiBold : Font.Normal
                            elide: Text.ElideRight
                            width: 200
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedGridIndex = index;
                            root.isGridFocused = true;
                            root.triggerCurrent();
                        }
                    }
                }
            }
        }
    }

    function selectPrevious() {
        if (!isGridFocused) {
            if (selectedCategoryIndex > 0) {
                selectedCategoryIndex--;
                selectedGridIndex = 0;
                return true;
            }
        } else {
            if (selectedGridIndex % 5 > 0) {
                selectedGridIndex--;
                return true;
            } else {
                isGridFocused = false;
                return true;
            }
        }
        return false;
    }

    function selectNext() {
        if (!isGridFocused) {
            isGridFocused = true;
            return true;
        } else {
            if (selectedGridIndex < filteredApps.length - 1) {
                selectedGridIndex++;
                return true;
            }
        }
        return false;
    }

    function selectUp() {
        if (!isGridFocused) {
            if (selectedCategoryIndex > 0) {
                selectedCategoryIndex--;
                return true;
            }
        } else {
            if (selectedGridIndex >= 5) {
                selectedGridIndex -= 5;
                return true;
            }
        }
        return false;
    }

    function selectDown() {
        if (!isGridFocused) {
            if (selectedCategoryIndex < libraryCategories.length - 1) {
                selectedCategoryIndex++;
                return true;
            }
        } else {
            if (selectedGridIndex + 5 < filteredApps.length) {
                selectedGridIndex += 5;
                return true;
            }
        }
        return false;
    }

    function triggerCurrent() {
        if (isGridFocused && selectedGridIndex >= 0 && selectedGridIndex < filteredApps.length) {
            var app = filteredApps[selectedGridIndex];
            appSelected(app);
        } else if (!isGridFocused) {
            isGridFocused = true;
        }
    }
}
