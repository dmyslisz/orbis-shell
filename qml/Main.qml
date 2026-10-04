import QtQuick
import QtQuick.Window
import QtQuick.Controls

Window {
    id: appWindow
    visible: true
    width: 1920
    height: 1080
    visibility: Window.FullScreen
    title: "Orbis OS Shell"
    color: "#001030"

    // Always ensure keyHandler retains keyboard focus
    onActiveFocusItemChanged: {
        if (!activeFocusItem || (userSelectScreen.isCreatingUser && activeFocusItem === userSelectScreen.nameInputField)) {
            return;
        }
        keyHandler.forceActiveFocus();
    }

    Component.onCompleted: {
        keyHandler.forceActiveFocus();
    }

    // 1080p Stage container keeping 16:9 proportion on any display resolution
    Item {
        id: stage
        width: 1920
        height: 1080
        anchors.centerIn: parent
        scale: Math.min(appWindow.width / 1920, appWindow.height / 1080)
        clip: true

        // Read tunables
        readonly property var tunables: configManager.tunables
        readonly property var motionTunables: tunables ? tunables.motion : null

        // Active UI section:
        // "welcome", "users", "tiles", "topbar", "deck", "options", "quickmenu", "settings", "library", "trophies", "notifications", "power"
        property string activeSection: "welcome"

        // Active user profile state
        property string currentUserName: configManager.activeUser ? configManager.activeUser : "User 1"
        property string currentUserAvatar: "qrc:/assets/avatars/avatar_luchador.svg"

        Component.onCompleted: {
            soundController.playLoginTheme();
        }

        // ==========================================
        // 1. DYNAMIC ORBIS FLOWING RIBBON BACKGROUND
        // ==========================================
        BackgroundWave {
            id: bgWave
            driftSpeed: (stage.motionTunables && stage.motionTunables.backgroundDriftSpeed) ? stage.motionTunables.backgroundDriftSpeed : 0.00045
        }

        // ==========================================
        // 2. WELCOME SCREEN ("Press the PS button...")
        // ==========================================
        WelcomeScreen {
            id: welcomeScreen
            opacity: stage.activeSection === "welcome" ? 1.0 : 0.0
            visible: opacity > 0.01
            enabled: stage.activeSection === "welcome"

            onProceed: {
                stage.activeSection = "users";
                soundController.playConfirm();
            }

            Behavior on opacity {
                NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
            }
        }

        // ==========================================
        // 3. USER SELECTION SCREEN ("Who is using this controller?")
        // ==========================================
        UserSelectScreen {
            id: userSelectScreen
            keyboardItem: virtualKeyboard
            opacity: stage.activeSection === "users" ? 1.0 : 0.0
            visible: opacity > 0.01
            enabled: stage.activeSection === "users"

            onUserLoggedIn: function(user) {
                stage.currentUserName = user.name;
                if (user.avatar) {
                    stage.currentUserAvatar = user.avatar;
                }
                configManager.activeUser = user.name;
                stage.activeSection = "tiles";
                soundController.stopLoginTheme();
                soundController.playLogin();
                soundController.playHomeScreenMusic();
            }

            onReturnToWelcome: {
                stage.activeSection = "welcome";
            }

            Behavior on opacity {
                NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
            }
        }

        // ==========================================
        // 4. TOP FUNCTION BAR & STATUS
        // ==========================================
        TopBar {
            id: topBar
            anchors.fill: parent
            isFocused: stage.activeSection === "topbar"
            userName: stage.currentUserName
            userAvatar: stage.currentUserAvatar
            visible: (stage.activeSection === "tiles" || stage.activeSection === "topbar" || stage.activeSection === "deck" || stage.activeSection === "options" || stage.activeSection === "quickmenu")
            opacity: (stage.activeSection === "tiles" || stage.activeSection === "topbar" || stage.activeSection === "deck" || stage.activeSection === "options") ? 1.0 : (stage.activeSection === "quickmenu" ? 0.35 : 0.0)

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }
        }

        // ==========================================
        // 5. MAIN HORIZONTAL TILE ROW
        // ==========================================
        TileRow {
            id: tileRow
            appsModel: configManager.apps
            isRowFocused: stage.activeSection === "tiles"
            isDeckActive: stage.activeSection === "deck"
            visible: (stage.activeSection === "tiles" || stage.activeSection === "topbar" || stage.activeSection === "deck" || stage.activeSection === "options" || stage.activeSection === "quickmenu")
            opacity: (stage.activeSection === "tiles" || stage.activeSection === "topbar" || stage.activeSection === "options") ? 1.0 : (stage.activeSection === "deck" ? 0.35 : (stage.activeSection === "quickmenu" ? 0.35 : 0.0))

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }

            onItemFocused: function(index, appData) {
                if (appData) {
                    bgWave.setAccent(appData.gradientStart);
                }
            }
        }

        // ==========================================
        // 6. CONTEXT / OVERVIEW DECK
        // ==========================================
        ContextArea {
            id: contextArea
            isOpen: stage.activeSection === "deck"
            currentAppData: tileRow.currentItem()

            onLaunchRequested: {
                stage.activeSection = "tiles";
                launchCurrentApp();
            }

            onCloseRequested: {
                stage.activeSection = "tiles";
                soundController.playBack();
            }
        }

        // ==========================================
        // 7. OPTIONS SLIDE-IN PANEL
        // ==========================================
        OptionsPanel {
            id: optionsPanel
            anchors.fill: parent
            z: 50
            isOpen: stage.activeSection === "options"
            currentAppData: tileRow.currentItem()

            onCloseRequested: {
                stage.activeSection = "tiles";
                soundController.playBack();
            }

            onActionTriggered: function(actionId, appData) {
                if (actionId === "start") {
                    stage.activeSection = "tiles";
                    launchCurrentApp();
                } else if (actionId === "close") {
                    stage.activeSection = "tiles";
                    processLauncher.terminateCurrentApp();
                    soundController.playBack();
                } else {
                    soundController.playConfirm();
                    showNotification(actionId.toUpperCase() + ": " + (appData ? appData.name : ""));
                }
            }
        }

        // ==========================================
        // 8. QUICK MENU (PS4 Guide Button Overlay)
        // ==========================================
        QuickMenu {
            id: quickMenu
            anchors.fill: parent
            z: 50
            isOpen: stage.activeSection === "quickmenu"
            userName: stage.currentUserName
            userAvatar: stage.currentUserAvatar

            onCloseRequested: {
                stage.activeSection = "tiles";
                soundController.playBack();
            }

            onActionTriggered: function(actionId) {
                if (actionId === "power") {
                    stage.activeSection = "power";
                    soundController.playConfirm();
                }
            }
        }

        // ==========================================
        // 9. FULL SCREEN MODAL VIEWS
        // ==========================================
        SettingsView {
            id: settingsView
            z: 100
            isOpen: stage.activeSection === "settings"
            onCloseRequested: {
                stage.activeSection = "topbar";
                soundController.playBack();
            }
        }

        LibraryView {
            id: libraryView
            z: 100
            isOpen: stage.activeSection === "library"
            onCloseRequested: {
                stage.activeSection = "tiles";
                soundController.playBack();
            }
            onAppSelected: function(app) {
                stage.activeSection = "tiles";
                soundController.playConfirm();
                launchAppDirect(app);
            }
        }


        NotificationsView {
            id: notifView
            z: 100
            isOpen: stage.activeSection === "notifications"
            onCloseRequested: {
                stage.activeSection = "topbar";
                soundController.playBack();
            }
        }

        PowerMenu {
            id: powerMenu
            z: 100
            isOpen: stage.activeSection === "power"
            onCloseRequested: {
                stage.activeSection = (stage.activeSection === "quickmenu" ? "tiles" : "topbar");
                soundController.playBack();
            }
            onSwitchUserRequested: {
                stage.activeSection = "users";
                soundController.stopHomeScreenMusic();
                soundController.playLoginTheme();
            }
        }

        // ==========================================
        // APP LAUNCH ZOOM & SPLASH OVERLAY
        // ==========================================
        AppLaunchSplash {
            id: launchSplash
        }

        // ==========================================
        // AUTHENTIC PS4 VIRTUAL KEYBOARD OVERLAY
        // ==========================================
        VirtualKeyboard {
            id: virtualKeyboard
            z: 500
        }



        // Subtle toast banner for standard notifications
        Rectangle {
            id: toastBanner
            anchors.bottom: bottomBar.top
            anchors.bottomMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            width: toastText.implicitWidth + 48
            height: 44
            radius: 4
            color: "#e6002152"
            border.color: "#ffffff"
            border.width: 1.5
            opacity: 0.0
            z: 400

            Behavior on opacity {
                NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
            }

            Text {
                id: toastText
                anchors.centerIn: parent
                color: "#ffffff"
                font.pixelSize: 16
                font.weight: Font.Medium
            }

            Timer {
                id: toastTimer
                interval: 2600
                onTriggered: toastBanner.opacity = 0.0
            }
        }

        // ==========================================
        // 12. BOTTOM STATUS BAR & ACTION PROMPTS
        // ==========================================
        Item {
            id: bottomBar
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 26
            anchors.left: parent.left
            anchors.leftMargin: 80
            anchors.right: parent.right
            anchors.rightMargin: 80
            height: 36
            opacity: (stage.activeSection === "tiles" || stage.activeSection === "topbar" || stage.activeSection === "deck" || stage.activeSection === "options") ? 1.0 : 0.0
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
            }

            // Left side action hints
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 24

                // (A) Start / Enter
                Row {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter

                    GamepadBadge {
                        button: "A"
                        size: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: (stage.activeSection === "tiles") ? "Start" : "Enter"
                        color: "#ffffff"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // (B) Back (shown when in options, topbar, or deck)
                Row {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter
                    visible: (stage.activeSection === "options" || stage.activeSection === "topbar" || stage.activeSection === "deck")

                    GamepadBadge {
                        button: "B"
                        size: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Back"
                        color: "#ffffff"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // [OPTIONS] Options Menu (shown on tiles or options)
                Row {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter
                    visible: (stage.activeSection === "tiles" || stage.activeSection === "options")

                    GamepadBadge {
                        button: "OPTIONS"
                        size: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Options Menu"
                        color: "#ffffff"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Right side: Active User Profile
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    width: 24
                    height: 24
                    radius: 3
                    color: "#1a3560"
                    anchors.verticalCenter: parent.verticalCenter
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: stage.currentUserAvatar
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: stage.currentUserName
                    color: "#ffffff"
                    font.pixelSize: 16
                }
            }
        }
    }

    function showNotification(msg) {
        soundController.playNotification();
        toastText.text = msg;
        toastBanner.opacity = 1.0;
        toastTimer.restart();
    }

    function launchCurrentApp() {
        var item = tileRow.currentItem();
        if (!item) return;

        if (item.id === "library") {
            stage.activeSection = "library";
            soundController.playConfirm();
            return;
        }

        launchAppDirect(item);
    }

    function launchAppDirect(item) {
        soundController.playConfirm();
        launchSplash.startLaunch(item);
        if (item.exec && item.exec.length > 0) {
            var started = processLauncher.launch(item.name, item.exec);
            if (!started) {
                showNotification("Could not start '" + item.exec + "' (check if installed)");
            }
        } else {
            showNotification(item.name + " selected");
        }
    }

    // Navigation and Action Handlers
    function handleLeft() {
        if (virtualKeyboard.isOpen) {
            virtualKeyboard.selectLeft();
            return;
        }
        if (stage.activeSection === "users") {
            userSelectScreen.selectPrevious();
        } else if (stage.activeSection === "tiles") {
            if (tileRow.selectPrevious()) soundController.playTick();
        } else if (stage.activeSection === "topbar") {
            if (topBar.selectPrevious()) soundController.playTick();
        } else if (stage.activeSection === "deck") {
            if (contextArea.selectPrevious()) soundController.playTick();
        } else if (stage.activeSection === "library") {
            if (libraryView.selectPrevious()) soundController.playTick();
        } else if (stage.activeSection === "quickmenu") {
            quickMenu.handleLeft();
        } else if (stage.activeSection === "settings") {
            settingsView.handleLeft();
        }
    }

    function handleRight() {
        if (virtualKeyboard.isOpen) {
            virtualKeyboard.selectRight();
            return;
        }
        if (stage.activeSection === "users") {
            userSelectScreen.selectNext();
        } else if (stage.activeSection === "tiles") {
            if (tileRow.selectNext()) soundController.playTick();
        } else if (stage.activeSection === "topbar") {
            if (topBar.selectNext()) soundController.playTick();
        } else if (stage.activeSection === "deck") {
            if (contextArea.selectNext()) soundController.playTick();
        } else if (stage.activeSection === "library") {
            if (libraryView.selectNext()) soundController.playTick();
        } else if (stage.activeSection === "quickmenu") {
            quickMenu.handleRight();
        } else if (stage.activeSection === "settings") {
            settingsView.handleRight();
        }
    }

    function handleUp() {
        if (virtualKeyboard.isOpen) {
            virtualKeyboard.selectUp();
            return;
        }
        if (stage.activeSection === "users") {
            userSelectScreen.selectUp();
        } else if (stage.activeSection === "tiles") {
            stage.activeSection = "topbar";
            soundController.playTick();
        } else if (stage.activeSection === "deck") {
            stage.activeSection = "tiles";
            soundController.playTick();
        } else if (stage.activeSection === "quickmenu") {
            quickMenu.handleUp();
        } else if (stage.activeSection === "options") {
            if (optionsPanel.selectPrevious()) soundController.playTick();
        } else if (stage.activeSection === "settings") {
            settingsView.handleUp();
        } else if (stage.activeSection === "library") {
            if (libraryView.selectUp()) soundController.playTick();
        } else if (stage.activeSection === "notifications") {
            if (notifView.selectPrevious()) soundController.playTick();
        } else if (stage.activeSection === "power") {
            if (powerMenu.selectPrevious()) soundController.playTick();
        }
    }

    function handleDown() {
        if (virtualKeyboard.isOpen) {
            virtualKeyboard.selectDown();
            return;
        }
        if (stage.activeSection === "users") {
            userSelectScreen.selectDown();
        } else if (stage.activeSection === "topbar") {
            stage.activeSection = "tiles";
            soundController.playTick();
        } else if (stage.activeSection === "tiles") {
            stage.activeSection = "deck";
            soundController.playTick();
        } else if (stage.activeSection === "quickmenu") {
            quickMenu.handleDown();
        } else if (stage.activeSection === "options") {
            if (optionsPanel.selectNext()) soundController.playTick();
        } else if (stage.activeSection === "settings") {
            settingsView.handleDown();
        } else if (stage.activeSection === "library") {
            if (libraryView.selectDown()) soundController.playTick();
        } else if (stage.activeSection === "notifications") {
            if (notifView.selectNext()) soundController.playTick();
        } else if (stage.activeSection === "power") {
            if (powerMenu.selectNext()) soundController.playTick();
        }
    }

    function handleConfirm() {
        if (virtualKeyboard.isOpen) {
            virtualKeyboard.triggerCurrent();
            return;
        }
        if (stage.activeSection === "welcome") {
            stage.activeSection = "users";
            soundController.playConfirm();
        } else if (stage.activeSection === "users") {
            userSelectScreen.triggerCurrent();
        } else if (stage.activeSection === "tiles") {
            launchCurrentApp();
        } else if (stage.activeSection === "deck") {
            contextArea.triggerCurrent();
        } else if (stage.activeSection === "topbar") {
            var item = topBar.currentItem();
            if (item) {
                soundController.playConfirm();
                if (item.id === "settings") {
                    stage.activeSection = "settings";
                } else if (item.id === "notifications") {
                    stage.activeSection = "notifications";
                } else if (item.id === "power") {
                    stage.activeSection = "power";
                }
            }
        } else if (stage.activeSection === "options") {
            optionsPanel.triggerCurrent();
        } else if (stage.activeSection === "quickmenu") {
            quickMenu.handleConfirm();
        } else if (stage.activeSection === "settings") {
            settingsView.handleConfirm();
        } else if (stage.activeSection === "library") {
            libraryView.triggerCurrent();
        } else if (stage.activeSection === "power") {
            powerMenu.triggerCurrent();
        }
    }

    function handleBack() {
        if (virtualKeyboard.isOpen) {
            virtualKeyboard.close();
            return;
        }
        if (stage.activeSection === "users") {
            userSelectScreen.cancelCurrent();
        } else if (stage.activeSection === "deck") {
            stage.activeSection = "tiles";
            soundController.playBack();
        } else if (stage.activeSection === "topbar") {
            stage.activeSection = "tiles";
            soundController.playBack();
        } else if (stage.activeSection === "options") {
            if (!optionsPanel.handleBack()) {
                stage.activeSection = "tiles";
                soundController.playBack();
            }
        } else if (stage.activeSection === "quickmenu") {
            if (!quickMenu.handleBack()) {
                stage.activeSection = "tiles";
                soundController.playBack();
            }
        } else if (stage.activeSection === "settings") {
            if (!settingsView.handleBack()) {
                stage.activeSection = "topbar";
                soundController.playBack();
            }
        } else if (stage.activeSection === "notifications" || stage.activeSection === "power") {
            stage.activeSection = "topbar";
            soundController.playBack();
        } else if (stage.activeSection === "library") {
            stage.activeSection = "tiles";
            soundController.playBack();
        }
    }

    function handleOptions() {
        if (virtualKeyboard.isOpen) return;
        if (stage.activeSection === "users") {
            userSelectScreen.openOptions();
            return;
        }
        soundController.playOptions();
        if (stage.activeSection === "options") {
            stage.activeSection = "tiles";
        } else if (stage.activeSection === "tiles") {
            stage.activeSection = "options";
        }
    }

    function handleHome() {
        if (stage.activeSection === "welcome") {
            stage.activeSection = "users";
            soundController.playConfirm();
        } else if (stage.activeSection === "quickmenu" || stage.activeSection === "options" || stage.activeSection === "settings" || stage.activeSection === "library" || stage.activeSection === "trophies" || stage.activeSection === "notifications" || stage.activeSection === "power" || stage.activeSection === "deck" || stage.activeSection === "topbar") {
            stage.activeSection = "tiles";
            soundController.playBack();
        }
    }

    function handleQuickMenu() {
        soundController.playOptions();
        if (stage.activeSection === "quickmenu") {
            stage.activeSection = "tiles";
        } else {
            stage.activeSection = "quickmenu";
        }
    }

    // Connect Gamepad signals
    Connections {
        target: gamepadManager
        function onNavigateLeft() { handleLeft(); }
        function onNavigateRight() { handleRight(); }
        function onNavigateUp() { handleUp(); }
        function onNavigateDown() { handleDown(); }
        function onConfirmPressed() { handleConfirm(); }
        function onBackPressed() { handleBack(); }
        function onOptionsPressed() { handleOptions(); }
        function onHomePressed() { handleHome(); }
        function onQuickMenuRequested() { handleQuickMenu(); }
        function onTrianglePressed() {
            if (stage.activeSection === "tiles") {
                stage.activeSection = "library";
                soundController.playConfirm();
            }
        }
    }

    // Keyboard navigation
    Item {
        id: keyHandler
        focus: true
        Keys.onPressed: function(event) {
            if (event.isAutoRepeat) return;
            if (virtualKeyboard.isOpen) return;

            if (event.key === Qt.Key_Left || event.key === Qt.Key_A) {
                gamepadManager.handleNavigationPress(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_D) {
                gamepadManager.handleNavigationPress(2);
                event.accepted = true;
            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_W) {
                gamepadManager.handleNavigationPress(3);
                event.accepted = true;
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_S) {
                gamepadManager.handleNavigationPress(4);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                handleConfirm();
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Backspace) {
                handleBack();
                event.accepted = true;
            } else if (event.key === Qt.Key_O || event.key === Qt.Key_Tab || event.key === Qt.Key_F1) {
                handleOptions();
                event.accepted = true;
            } else if (event.key === Qt.Key_Home || event.key === Qt.Key_F12 || event.key === Qt.Key_Super_L) {
                handleHome();
                event.accepted = true;
            } else if (event.key === Qt.Key_Q || event.key === Qt.Key_F2) {
                handleQuickMenu();
                event.accepted = true;
            }
        }

        Keys.onReleased: function(event) {
            if (event.isAutoRepeat) return;
            if (stage.activeSection === "users" && userSelectScreen.isCreatingUser) return;

            if (event.key === Qt.Key_Left || event.key === Qt.Key_A) {
                gamepadManager.handleNavigationRelease(1);
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_D) {
                gamepadManager.handleNavigationRelease(2);
            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_W) {
                gamepadManager.handleNavigationRelease(3);
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_S) {
                gamepadManager.handleNavigationRelease(4);
            }
        }
    }
}
