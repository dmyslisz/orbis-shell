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

    property bool isOptionsMenuOpen: false
    property int optionsSelectedIndex: 0

    signal appSelected(var appData)
    signal closeRequested()
    signal notificationRequested(string message, string icon)

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
            var scanned = appScanner.installedApps[j];
            // Ensure no duplicate if already present in baseList
            var exists = false;
            for (var k = 0; k < baseList.length; ++k) {
                if (baseList[k].id === scanned.id || baseList[k].name === scanned.name) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                baseList.push(scanned);
            }
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

    readonly property var currentApp: (isGridFocused && selectedGridIndex >= 0 && selectedGridIndex < filteredApps.length) ? filteredApps[selectedGridIndex] : null
    readonly property bool isCurrentAppOnHome: currentApp ? configManager.isAppOnHomeScreen(currentApp.id ? currentApp.id : currentApp.name) : false

    readonly property var currentAppOptions: {
        if (!currentApp) return [];
        var opts = [];
        if (isCurrentAppOnHome) {
            opts.push({ id: "remove_home", name: "Remove from Home Screen", icon: "qrc:/assets/icons/close_app.svg" });
        } else {
            opts.push({ id: "add_home", name: "Add to Home Screen", icon: "qrc:/assets/icons/launcher_logo.svg" });
        }
        opts.push({ id: "start", name: "Start Application", icon: "qrc:/assets/icons/gamepad.svg" });
        return opts;
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

            // Action hints in Header
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 20

                Row {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter
                    GamepadBadge {
                        button: "A"
                        size: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: root.isOptionsMenuOpen ? "Select" : (root.isGridFocused ? "Start" : "Select")
                        color: "#ffffff"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.isGridFocused && !root.isOptionsMenuOpen
                    GamepadBadge {
                        button: "OPTIONS"
                        size: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Options"
                        color: "#ffffff"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter
                    GamepadBadge {
                        button: "B"
                        size: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Back"
                        color: "#ffffff"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
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

                    readonly property bool isSelected: !root.isGridFocused && !root.isOptionsMenuOpen && root.selectedCategoryIndex === index
                    readonly property bool isCurrentCat: root.selectedCategoryIndex === index

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: isSelected ? "#16325c" : (isCurrentCat ? "#142848" : "transparent")
                        border.color: isSelected ? "#ffffff" : "transparent"
                        border.width: isSelected ? 2.5 : 0

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.name
                            color: "#ffffff"
                            font.pixelSize: 19
                            font.weight: (isSelected || isCurrentCat) ? Font.DemiBold : Font.Normal
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedCategoryIndex = index;
                            root.selectedGridIndex = 0;
                            root.isGridFocused = false;
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

                    readonly property bool isSelected: root.isGridFocused && !root.isOptionsMenuOpen && root.selectedGridIndex === index

                    Column {
                        anchors.centerIn: parent
                        spacing: 12

                        Rectangle {
                            width: 180
                            height: 140
                            radius: 4
                            color: "#102344"
                            scale: isSelected ? 1.06 : 1.0
                            clip: true

                            Behavior on scale { NumberAnimation { duration: 150 } }

                            Image {
                                anchors.fill: parent
                                source: modelData.icon ? modelData.icon : "qrc:/assets/icons/gamepad.svg"
                                fillMode: Image.PreserveAspectCrop
                            }

                            // Outline border on top of image
                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: "transparent"
                                border.color: isSelected ? "#ffffff" : "#25ffffff"
                                border.width: isSelected ? 3.5 : 1
                                z: 10
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

        // ==========================================
        // PS4-STYLE CONTEXTUAL OPTIONS SIDEBAR
        // ==========================================
        Rectangle {
            id: optionsSidebar
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 380
            color: "#f2081426"
            border.color: "#30ffffff"
            border.width: 1
            visible: root.isOptionsMenuOpen
            z: 200

            MouseArea {
                anchors.fill: parent
                // absorb clicks inside sidebar
            }

            Column {
                anchors.fill: parent
                anchors.margins: 28
                anchors.topMargin: 40
                spacing: 20

                // Focused App Header
                Row {
                    spacing: 14
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 4
                        color: "#162846"
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            anchors.fill: parent
                            source: root.currentApp ? (root.currentApp.icon || "qrc:/assets/icons/gamepad.svg") : "qrc:/assets/icons/gamepad.svg"
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    Text {
                        text: root.currentApp ? root.currentApp.name : "Options"
                        color: "#ffffff"
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        width: parent.width - 56
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#25ffffff"
                }

                // Options list
                Repeater {
                    model: root.currentAppOptions

                    Item {
                        required property int index
                        required property var modelData
                        width: parent.width
                        height: 52

                        readonly property bool isSelected: root.optionsSelectedIndex === index

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: isSelected ? "#16325c" : "transparent"
                            border.color: isSelected ? "#ffffff" : "transparent"
                            border.width: isSelected ? 2.5 : 0

                            Row {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 14

                                Image {
                                    width: 22
                                    height: 22
                                    source: modelData.icon
                                    fillMode: Image.PreserveAspectFit
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.name
                                    color: "#ffffff"
                                    font.pixelSize: 16
                                    font.weight: isSelected ? Font.DemiBold : Font.Normal
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.optionsSelectedIndex = index;
                                root.triggerOptionsAction();
                            }
                        }
                    }
                }
            }
        }
    }

    // Console Navigation
    function selectPrevious() {
        if (root.isOptionsMenuOpen) return true;
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
        if (root.isOptionsMenuOpen) return true;
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
        if (root.isOptionsMenuOpen) {
            if (optionsSelectedIndex > 0) {
                optionsSelectedIndex--;
                soundController.playTick();
                return true;
            }
            return true;
        }
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
        if (root.isOptionsMenuOpen) {
            if (optionsSelectedIndex < currentAppOptions.length - 1) {
                optionsSelectedIndex++;
                soundController.playTick();
                return true;
            }
            return true;
        }
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
        if (root.isOptionsMenuOpen) {
            triggerOptionsAction();
            return;
        }
        if (isGridFocused && selectedGridIndex >= 0 && selectedGridIndex < filteredApps.length) {
            var app = filteredApps[selectedGridIndex];
            appSelected(app);
        } else if (!isGridFocused) {
            isGridFocused = true;
        }
    }

    function openOptions() {
        if (isGridFocused && currentApp) {
            optionsSelectedIndex = 0;
            isOptionsMenuOpen = true;
            soundController.playOptions();
            return true;
        }
        return false;
    }

    function triggerOptionsAction() {
        if (!currentApp || optionsSelectedIndex < 0 || optionsSelectedIndex >= currentAppOptions.length) return;
        var opt = currentAppOptions[optionsSelectedIndex];
        soundController.playConfirm();
        if (opt.id === "add_home") {
            configManager.addAppToHomeScreen(currentApp);
            root.isOptionsMenuOpen = false;
            root.notificationRequested("Successfully added " + currentApp.name + " to Home Screen", currentApp.icon || "qrc:/assets/icons/launcher_logo.svg");
        } else if (opt.id === "remove_home") {
            configManager.removeAppFromHomeScreen(currentApp.id ? currentApp.id : currentApp.name);
            root.isOptionsMenuOpen = false;
            root.notificationRequested("Removed " + currentApp.name + " from Home Screen", currentApp.icon || "qrc:/assets/icons/close_app.svg");
        } else if (opt.id === "start") {
            root.isOptionsMenuOpen = false;
            root.appSelected(currentApp);
        }
    }

    function handleBack() {
        if (root.isOptionsMenuOpen) {
            root.isOptionsMenuOpen = false;
            soundController.playBack();
            return true;
        }
        return false;
    }
}
