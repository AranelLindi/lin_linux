#!/bin/bash

# Generell: alles was nah an Hardware ist und Performance braucht -> mit dnf installieren
# Alles andere über flatpak

# Updatebefehle:
# $ sudo dnf upgrade --refresh
# $ flatpak update -y

set -e

echo "======================================"
echo " Fedora Gaming Setup & Check Script"
echo "======================================"
echo ""

########################################
# STEP 1: SYSTEM CHECKS
########################################

echo "==[ System Checks ]=="
echo ""

# AMDGPU
echo -n "Checking amdgpu module... "
if lsmod | grep -q amdgpu; then
    echo "OK"
else
    echo "MISSING (AMD driver not loaded!)"
fi

# Mesa / OpenGL
echo -n "Checking Mesa (OpenGL)... "
if command -v glxinfo &> /dev/null; then
    renderer=$(glxinfo | grep "OpenGL renderer" || true)
    if [[ -n "$renderer" ]]; then
        echo "OK ($renderer)"
    else
        echo "UNKNOWN"
    fi
else
    echo "glxinfo missing (mesa-demos not installed)"
fi

# Vulkan
echo -n "Checking Vulkan... "
if command -v vulkaninfo &> /dev/null; then
    echo "OK"
else
    echo "MISSING"
fi

# NTSYNC
echo -n "Checking NTSYNC... "
if zgrep -q NTSYNC /proc/config.gz 2>/dev/null; then
    if zgrep -q "CONFIG_NTSYNC=y" /proc/config.gz; then
        echo "ENABLED"
    else
        echo "NOT ENABLED"
    fi
else
    echo "UNKNOWN (kernel config not accessible)"
fi

# Flatpak
echo -n "Checking Flatpak... "
if command -v flatpak &> /dev/null; then
    echo "OK"
else
    echo "NOT INSTALLED"
fi

echo ""
echo "======================================"
echo ""

########################################
# STEP 2: USER CONFIRMATION
########################################

read -p "Continue with installation? (y/n): " confirm

if [[ "$confirm" != "y" ]]; then
    echo "Aborted."
    exit 0
fi

########################################
# STEP 3: INSTALLATION
########################################

echo ""
echo "==[ Installing Components ]=="

# RPM Fusion (idempotent)
echo "Adding RPM Fusion repositories..."
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
  || true

# System update
echo "Updating system..."
sudo dnf update -y

# Core packages
# Steam: Gaming platform (native Linux client, uses Proton for Windows games)
# MangoHud: Ingame performance overlay (FPS, frametime, CPU/GPU usage, temps)
# GameMode: Background daemon that temporarily applies performance tweaks (CPU governor, scheduling, I/O priority, disables screensaver, etc.)
# Lutris: Universal game launcher and installer using community scripts for non-Steam games (e.g. Battle.net, Epic Games, GOG)
# Wine: Compatibility layer that translates Windows API calls to Linux (NOT an emulator; used to run Windows applications/games)
# Winetricks: Helper tool for Wine to install additional Windows components (fonts, DLLs, redistributables like .NET, DirectX, etc.)
# Vulkan-Tools: Utilities for Vulkan (e.g. 'vulkaninfo') to verify Vulkan support
# Mesa-Demos: OpenGL utilities (e.g. 'glxinfo', 'glxgears') for testing Mesa/driver setup
# GameScope: Lightweight micro-compositor (from Valve) for games. Enables resolution scaling FSR1, better frame pacing, fullscreen isolation
# vkbasalt: Vulkan post-processing layer (e.g. sharpening, FXAA) often used to improve image quality when using FSR
# ProtonUp-Qt: Wird unten via Flatpak installiert - hier NICHT hinzufügen !
echo "Installing core gaming packages..."
sudo dnf install -y \
  steam \
  mangohud \
  gamemode \
  lutris \
  wine \
  winetricks \
  vulkan-tools \
  mesa-demos \
  gamescope \
  vkbasalt \
  || true

# Codecs (wichtig! Müllt System nicht zu)
echo "Installing multimedia codecs..."
sudo dnf install -y \
  gstreamer1-plugins-good \
  gstreamer1-plugins-bad-free \
  gstreamer1-plugins-bad-freeworld \
  gstreamer1-plugins-ugly \
  gstreamer1-libav \
  || true

# Flatpak (falls fehlt)
if ! command -v flatpak &> /dev/null; then
    echo "Installing Flatpak..."
    sudo dnf install -y flatpak
fi

# Flathub Repo
echo "Adding Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Flatpak Apps
echo "Installing Flatpak apps..."
# ProtonUp-Qt
flatpak install -y flathub net.davidotek.pupgui2
# OBS Studio
flatpak install -y flathub com.obsproject.Studio

echo ""
echo "======================================"
echo " Installation complete!"
echo "======================================"

########################################
# STEP 4: CHEAT SHEET
########################################

echo ""
echo "==[ Gaming Cheat Sheet ]=="
echo ""

echo "Steam Launch Options (Standard):"
echo "  mangohud gamemoderun %command%"
echo ""

echo "Proton FSR (Fallback Upscaling):"
echo "  WINE_FULLSCREEN_FSR=1 %command%"
echo ""

echo "FSR + Overlay + Performance:"
echo "  mangohud gamemoderun WINE_FULLSCREEN_FSR=1 %command%"
echo ""

echo "Gamescope FSR (FSR1, advanced):"
echo "  gamescope -f -F fsr -w 1280 -h 720 -W 2560 -H 1440 -- %command%"
echo ""

echo "Full Combo:"
echo "  mangohud gamemoderun gamescope -f -F fsr -w 1280 -h 720 -W 2560 -H 1440 -- %command%"
echo ""

echo "FSR Strategy:"
echo "  1. Use in-game FSR (best quality)"
echo "  2. Use Proton FSR (fallback)"
echo "  3. Use Gamescope FSR (advanced control)"
echo ""

echo "Toggle MangoHud:"
echo "  Shift + F12"
echo ""

echo "Check Vulkan:"
echo "  vulkaninfo | less"
echo ""

echo "Check GPU:"
echo "  glxinfo | grep 'OpenGL renderer'"
echo ""

echo "Check NTSYNC:"
echo "  zgrep NTSYNC /proc/config.gz"
echo ""

echo "Install Proton-GE:"
echo "  Start ProtonUp-Qt → install latest GE version"
echo ""

echo "Notes:"
echo "  - Gamescope FSR uses FSR1 only"
echo "  - Wayland: no need to disable compositor"
echo "  - vkBasalt can improve FSR sharpness"
echo ""

echo "======================================"
echo " Done. Happy Gaming"
echo "======================================"
