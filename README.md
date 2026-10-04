# Orbis OS Shell (Fedora 44 / Wayland / X11)

A console desktop environment and launcher replicating the **PlayStation 4 Orbis OS** interface, built with **Qt 6 (QML / C++)** and **SDL3**. Designed as a complete desktop replacement (similar to [LineXinBar](https://github.com/Petexy/LineXinBar) and Steam Big Picture) for **Fedora Linux 44** and modern Wayland compositors.

Featuring the iconic dual-tier ribbon layout, parting content tiles, expanding focus with radiant aura, overview deck, slide-out options menu, quick menu overlay, settings hub, application library, trophy tracker, and authentic sound cues.

---

## Key Features & 1:1 Orbis OS Experience

1. **Dual-Tier Ribbon Architecture**:
   - **Top Function Area**:
     - PlayStation Plus, Notifications (with unread badge counter), Friends (with online status), Communities, Events, Messages, Party.
     - Profile (User avatar, Gamertag, trophy level pip).
     - Trophies (Golden cup, links to full trophy tracker).
     - Settings (Toolbox icon, opens full settings hub).
     - Power (Rest Mode, Turn Off, Restart, Switch User, Log Out).
     - Live clock, Wi-Fi status, and battery gauge in the top right corner.
   - **Main Content Ribbon**:
     - "What's New", installed Steam games, web browser, media players, RetroArch, terminal, and the Library tile.
     - Parting tile motion: neighboring tiles smoothly glide aside to accommodate the 1.14x enlarged focused tile.
     - Bottom drawer with down arrow indicating the Overview Deck.
     - App title and "Start" / "Resume" action button displayed beside the active tile.

2. **Overview / Activities Deck**:
   - Pressing **Down** on any game tile smoothly pulls up the full Overview Deck:
     - Large "Start" / "Resume" card with playtime indicator.
     - Recent Activities & patch notes.
     - Trophies progress bar for the selected game.
     - Pressing **Up** or **Circle / Back** glides back to the content row.

3. **Quick Menu (Hold PS Button / Guide)**:
   - Sliding dark drawer from the left edge when holding the controller's Guide button or pressing `Q` / `F2`.
   - Live Master Volume slider (adjusts Fedora PipeWire system audio via `wpctl`).
   - Mute audio toggle.
   - Background music (BGM) toggle.
   - Quick power shortcuts and running app termination.

4. **Options Menu (Options / Start Button)**:
   - Sliding dark drawer from the right edge with `options.wav`.
   - Contextual actions: "Start", "Close Application", "Check for Update", "Information", "Delete".
   - Full application information dialog showing executable path, version, and platform.

5. **Desktop Replacement & Linux Integration**:
   - **Dynamic App Discovery (`AppScanner`)**: Automatically discovers and categorizes installed Linux applications from `/usr/share/applications` and `~/.local/share/applications`.
   - **Steam Library Discovery (`SteamScanner`)**: Parses `libraryfolders.vdf` and `appmanifest_*.acf` across all drives, imports game covers/grid banners, and creates direct launch entries (`steam steam://rungameid/<id>`).
   - **Real Hardware Status (`SystemManager`)**: Reads battery level from `/sys/class/power_supply/`, network status from `/sys/class/net/`, storage metrics via `statvfs`, CPU/RAM stats, and controls system power via `systemctl` / `loginctl`.
   - **Desktop Session Entry**: Installs `orbis-shell-wayland.desktop` into `/usr/share/wayland-sessions/` and `/usr/share/xsessions/` so it appears as a selectable session in GDM or SDDM.

6. **Authentic Audio System**:
   - Mapped directly to the provided PlayStation 4 system sounds:
     - `boot_chime.wav`: Cold boot and welcome screen chime.
     - `home_screen_music.wav`: Ambient looping home screen soundtrack.
     - `nav_tick.wav`: Navigation ticks across tiles and menus.
     - `confirm.wav`: Confirm selection chime (Cross / Enter).
     - `back.wav`: Cancel / Back chime (Circle / Esc).
     - `options.wav`: Options menu slide sound.
     - `notification.wav`: Toast alert chime.
     - `trophy.wav`: Achievement unlock fanfare.
     - `login.wav` / `logout.wav`: User login and logout chimes.
     - Virtual keyboard sounds (`key_press.wav`, `cursor_move.wav`, `backspace.wav`, `key_error.wav`).

---

## Controls & Navigation

Navigation features an **accelerating hold-to-repeat** system identical across both gamepad and keyboard:

| Action | Gamepad (SDL3) | Keyboard | Mouse |
| :--- | :--- | :--- | :--- |
| **Navigate Left / Right** | D-Pad / Left Stick | `Left / Right` or `A / D` | Click tile |
| **Navigate Up / Down** | D-Pad / Left Stick | `Up / Down` or `W / S` | - |
| **Confirm / Start** | `South` (Cross / A) | `Return` / `Enter` / `Space` | Click item |
| **Back / Cancel** | `East` (Circle / B) | `Escape` / `Backspace` | Click Back button |
| **Options Menu** | `Start` / `Options` | `O` / `Tab` / `F1` | Click Options hint |
| **Home Screen (Tap)** | `Guide` (PS Button) | `Home` / `F12` / `Super` | - |
| **Quick Menu (Hold)** | `Guide` (Hold > 450ms) | `Q` / `F2` | - |
| **Quick Search / Library** | `North` (Triangle / Y) | `F3` / Click Search | Click search bar |
| **Volume Adjust (in Quick Menu)** | D-Pad Left / Right | `Left / Right` | Drag slider |

---

## Quick Start on Fedora 44

### 1. Automated Installation
Run the included installer script:

```bash
chmod +x session/install.sh
./session/install.sh
```

### 2. Manual Build & Install

```bash
# 1. Install required Fedora packages
sudo dnf install -y \
    cmake ninja-build gcc-c++ pkgconf-pkg-config \
    qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtmultimedia-devel qt6-qtwayland-devel \
    SDL3-devel pipewire wireplumber cage gamescope

# 2. Build the project
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j$(nproc)

# 3. Install system files (binaries & session desktop files)
sudo cmake --install build
sudo chmod +x /usr/bin/orbis-session
```

### 3. Running

- **Inside your current desktop session (Windowed / Fullscreen test)**:
  ```bash
  ./build/orbis-shell
  ```
- **As a standalone console session via Gamescope**:
  ```bash
  gamescope -f -e -- orbis-shell
  ```
- **As a full desktop replacement**:
  Log out of Fedora and select **"Orbis OS"** from your GDM or SDDM login manager screen.

---

## Directory Layout

```
orbis-shell/
├── CMakeLists.txt              # CMake build definition
├── resources.qrc               # Qt Resource definition
├── README.md                   # This documentation
├── src/                        # C++ core subsystems
│   ├── main.cpp                # Application entry point
│   ├── sound_controller.h/.cpp # Audio subsystem (SFX, BGM, SDL3/QtMultimedia)
│   ├── gamepad_manager.h/.cpp  # SDL3 Gamepad handler & hold-to-repeat
│   ├── process_launcher.h/.cpp # External process and game management
│   ├── app_scanner.h/.cpp      # XDG .desktop application discovery
│   ├── steam_scanner.h/.cpp    # Steam library and game manifest parser
│   ├── system_manager.h/.cpp   # Battery, PipeWire volume, power controls
│   └── config_manager.h/.cpp   # Configuration & hot-reload watcher
├── qml/                        # QML interface components
│   ├── Main.qml                # Main orchestrator & stage
│   ├── BackgroundWave.qml      # Dynamic flowing ribbon background
│   ├── WelcomeScreen.qml       # "Press PS button" boot screen
│   ├── UserSelectScreen.qml    # Profile selection
│   ├── TopBar.qml              # Function area ribbon
│   ├── TileRow.qml             # Horizontal content tile ribbon
│   ├── TileItem.qml            # Expanding tile item with aura
│   ├── ContextArea.qml         # Pull-down Overview Deck
│   ├── OptionsPanel.qml        # Right slide-out drawer
│   ├── QuickMenu.qml           # Left slide-out drawer (Hold PS button)
│   ├── SettingsView.qml        # Settings hub
│   ├── LibraryView.qml         # Full application browser & search
│   ├── TrophiesView.qml        # Trophies showcase
│   ├── NotificationsView.qml   # Notification history
│   ├── PowerMenu.qml           # Suspend, Turn Off, Restart modal
│   └── VirtualKeyboard.qml     # Virtual on-screen keyboard
├── assets/                     # Graphical & audio assets
│   ├── icons/                  # High-res SVG icons & button prompts
│   ├── covers/                 # 512x512 vector box arts
│   ├── avatars/                # Profile avatars
│   └── sounds/                 # Authentic PS4 UI WAV sounds
├── config/                     # Editable configuration files
│   ├── apps.json               # Default application tiles & context
│   ├── users.json              # User profiles & trophy levels
│   ├── tunables.json           # Timings, animations, audio levels
│   └── trophies.json           # System trophies & unlock criteria
└── session/                    # Linux desktop session integration
    ├── install.sh              # Fedora 44 setup script
    ├── orbis-session           # Display manager session runner
    ├── orbis-shell-wayland.desktop
    ├── orbis-shell-x11.desktop
    └── orbis-shell.desktop
```

---

## Live Tunables & Hot-Reloading

All timing values, easing curves, audio levels, and navigation speeds in `config/tunables.json` are watched live. Modifications to this file on disk take effect immediately without restarting the application:

```json
{
  "tile": {
    "width": 204,
    "height": 204,
    "focusedScale": 1.14,
    "scaleDurationMs": 190,
    "shiftDurationMs": 210,
    "spacing": 20,
    "borderWidth": 3.0,
    "focusBorderColor": "#ffffff",
    "focusGlowColor": "#99ccff"
  },
  "sound": {
    "masterVolume": 0.65,
    "sfxVolume": 0.70,
    "bgmVolume": 0.40,
    "bgmEnabled": true
  }
}
```
