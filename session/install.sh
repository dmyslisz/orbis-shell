#!/usr/bin/env bash
set -e

echo "=========================================================="
echo " Orbis OS Shell - Fedora 44 Setup & Installation"
echo "=========================================================="

# Check for root or sudo
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

echo "[1/4] Installing dependencies via DNF..."
$SUDO dnf install -y \
    cmake \
    ninja-build \
    gcc-c++ \
    pkgconf-pkg-config \
    qt6-qtbase-devel \
    qt6-qtdeclarative-devel \
    qt6-qtmultimedia-devel \
    qt6-qtwayland-devel \
    SDL3-devel \
    pipewire \
    wireplumber \
    cage \
    gamescope

echo "[2/4] Configuring build with CMake..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

cmake -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr

echo "[3/4] Building Orbis OS Shell..."
cmake --build build -j"$(nproc)"

echo "[4/4] Installing system session & binaries..."
$SUDO cmake --install build
$SUDO chmod +x /usr/bin/orbis-session

echo "=========================================================="
echo " Installation Complete!"
echo " How to use:"
echo " 1. Select 'Orbis OS' at the GDM/SDDM login screen."
echo " 2. Or test inside your current desktop session:"
echo "    orbis-shell"
echo " 3. Or run standalone via Gamescope:"
echo "    gamescope -f -e -- orbis-shell"
echo "=========================================================="
