#!/usr/bin/env bash

set -u

echo "========================================"
echo " Fedora KDE Applications Setup"
echo "========================================"
echo "Jede Anwendung und jeder Zusatzschritt"
echo "wird einzeln bestätigt."
echo

# --------------------------------------------------
# Flatpak prüfen
# --------------------------------------------------
if ! command -v flatpak >/dev/null 2>&1; then
    echo "Flatpak ist nicht installiert."
    read -r -p "Flatpak jetzt per dnf installieren? [y/N]: " reply
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
        sudo dnf install flatpak
    else
        echo "Flatpak wird nicht installiert."
    fi
    echo
fi

if command -v flatpak >/dev/null 2>&1; then
    if ! flatpak remote-list | awk '{print $1}' | grep -qx flathub; then
        echo "Flathub ist noch nicht eingerichtet."
        read -r -p "Flathub hinzufügen? [y/N]: " reply
        if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
            sudo flatpak remote-add --if-not-exists flathub \
                https://flathub.org/repo/flathub.flatpakrepo
        else
            echo "Flathub wird nicht hinzugefügt."
        fi
        echo
    fi
fi

# --------------------------------------------------
# Virtualization Stack
# --------------------------------------------------
echo "Virtualization Stack: KVM / QEMU / libvirt / virt-manager"
read -r -p "Installieren? [y/N]: " reply
if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
    sudo dnf install @virtualization
fi
echo

# --------------------------------------------------
# AusweisApp2
# --------------------------------------------------
if rpm -q AusweisApp2 >/dev/null 2>&1; then
    echo "AusweisApp2 ist bereits installiert."
else
    echo "AusweisApp2"
    read -r -p "Installieren? [y/N]: " reply
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
        sudo dnf install AusweisApp2
    fi
fi
echo

# --------------------------------------------------
# Filelight (Speicherplatzanzeige)
# --------------------------------------------------
if rpm -q filelight >/dev/null 2>&1; then
    echo "Filelight ist bereits installiert."
else
    echo "Filelight"
    read -r -p "Installieren? [y/N]: " reply
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
        sudo dnf install filelight
    fi
fi
echo

# --------------------------------------------------
# pavucontrol (Audiosteuerung)
# --------------------------------------------------
if rpm -q pavucontrol >/dev/null 2>&1; then
    echo "pavucontrol ist bereits installiert."
else
    echo "pavucontrol"
    read -r -p "Installieren? [y/N]: " reply
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
        sudo dnf install pavucontrol
    fi
fi
echo

# --------------------------------------------------
# VLC Player
# --------------------------------------------------
if rpm -q vlc >/dev/null 2>&1; then
    echo "VLC ist bereits installiert."
else
    echo "VLC"
    read -r -p "Installieren? [y/N]: " reply
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
        sudo dnf install vlc
    fi
fi
echo

# --------------------------------------------------
# Inkscape
# --------------------------------------------------
if rpm -q inkscape >/dev/null 2>&1; then
    echo "Inkscape ist bereits installiert."
else
    echo "Inkscape"
    read -r -p "Installieren? [y/N]: " reply
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
        sudo dnf install inkscape
    fi
fi
echo

# --------------------------------------------------
# Thunderbird
# --------------------------------------------------
if rpm -q thunderbird >/dev/null 2>&1; then
    echo "Thunderbird ist bereits installiert."
else
    echo "Thunderbird"
    read -r -p "Installieren? [y/N]: " reply
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
        sudo dnf install thunderbird
    fi
fi
echo

# --------------------------------------------------
# Wireshark
# --------------------------------------------------
if rpm -q wireshark >/dev/null 2>&1; then
    echo "Wireshark ist bereits installiert."
else
    echo "Wireshark"
    read -r -p "Installieren? [y/N]: " reply
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
        sudo dnf install wireshark
    fi
fi
echo

# --------------------------------------------------
# btop
# --------------------------------------------------
if rpm -q btop >/dev/null 2>&1; then
    echo "btop ist bereits installiert."
else
    echo "btop"
    read -r -p "Installieren? [y/N]: " reply
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
        sudo dnf install btop
    fi
fi
echo

# --------------------------------------------------
# CoolerControl (inkl. COPR Repository)
# --------------------------------------------------
if rpm -q coolercontrol >/dev/null 2>&1; then
    echo "CoolerControl ist bereits installiert."
else
    echo "CoolerControl (inkl. COPR Repository)"
    read -r -p "Installieren? [y/N]: " reply
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then

        if rpm -q dnf-plugins-core >/dev/null 2>&1; then
            echo "dnf-plugins-core ist bereits installiert."
        else
            echo "dnf-plugins-core wird benötigt (für COPR)."
            read -r -p "Installieren? [y/N]: " reply2
            if [[ "$reply2" == "y" || "$reply2" == "Y" ]]; then
                sudo dnf install dnf-plugins-core
            fi
        fi
        echo

        echo "CoolerControl COPR Repository aktivieren"
        read -r -p "Repository aktivieren? [y/N]: " reply3
        if [[ "$reply3" == "y" || "$reply3" == "Y" ]]; then
            sudo dnf copr enable codifryed/CoolerControl
        fi
        echo

        echo "CoolerControl installieren"
        read -r -p "Jetzt installieren? [y/N]: " reply4
        if [[ "$reply4" == "y" || "$reply4" == "Y" ]]; then
            sudo dnf install coolercontrol
        fi
        echo

        echo "coolercontrold Service aktivieren (Autostart + sofort starten)"
        read -r -p "Jetzt aktivieren? [y/N]: " reply5
        if [[ "$reply5" == "y" || "$reply5" == "Y" ]]; then
            sudo systemctl enable --now coolercontrold
        fi
    fi
fi
echo

# --------------------------------------------------
# lm_sensors (für sensors-detect)
# --------------------------------------------------
if rpm -q lm_sensors >/dev/null 2>&1; then
    echo "lm_sensors ist bereits installiert."
else
    echo "lm_sensors"
    read -r -p "Installieren? [y/N]: " reply
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
        sudo dnf install lm_sensors
    fi
fi
echo

# --------------------------------------------------
# Spotify
# --------------------------------------------------
if command -v flatpak >/dev/null 2>&1; then
    if flatpak info com.spotify.Client >/dev/null 2>&1; then
        echo "Spotify ist bereits installiert."
    else
        echo "Spotify (Flatpak)"
        read -r -p "Installieren? [y/N]: " reply
        if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
            flatpak install flathub com.spotify.Client
        fi
    fi
else
    echo "Spotify übersprungen, weil Flatpak nicht verfügbar ist."
fi
echo

# --------------------------------------------------
# Discord
# --------------------------------------------------
if command -v flatpak >/dev/null 2>&1; then
    if flatpak info com.discordapp.Discord >/dev/null 2>&1; then
        echo "Discord ist bereits installiert."
    else
        echo "Discord (Flatpak)"
        read -r -p "Installieren? [y/N]: " reply
        if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
            flatpak install flathub com.discordapp.Discord
        fi
    fi
else
    echo "Discord übersprungen, weil Flatpak nicht verfügbar ist."
fi
echo

# --------------------------------------------------
# Telegram Desktop
# --------------------------------------------------
if command -v flatpak >/dev/null 2>&1; then
    if flatpak info org.telegram.desktop >/dev/null 2>&1; then
        echo "Telegram Desktop ist bereits installiert."
    else
        echo "Telegram Desktop (Flatpak)"
        read -r -p "Installieren? [y/N]: " reply
        if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
            flatpak install flathub org.telegram.desktop
        fi
    fi
else
    echo "Telegram Desktop übersprungen, weil Flatpak nicht verfügbar ist."
fi
echo

# --------------------------------------------------
# Signal Desktop
# --------------------------------------------------
if command -v flatpak >/dev/null 2>&1; then
    if flatpak info org.signal.Signal >/dev/null 2>&1; then
        echo "Signal Desktop ist bereits installiert."
    else
        echo "Signal Desktop (Flatpak)"
        read -r -p "Installieren? [y/N]: " reply
        if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
            flatpak install flathub org.signal.Signal
        fi
    fi
else
    echo "Signal Desktop übersprungen, weil Flatpak nicht verfügbar ist."
fi
echo

# --------------------------------------------------
# Joplin
# --------------------------------------------------
if command -v flatpak >/dev/null 2>&1; then
    if flatpak info net.cozic.joplin_desktop >/dev/null 2>&1; then
        echo "Joplin ist bereits installiert."
    else
        echo "Joplin (Flatpak)"
        read -r -p "Installieren? [y/N]: " reply
        if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
            flatpak install flathub net.cozic.joplin_desktop
        fi
    fi
else
    echo "Joplin übersprungen, weil Flatpak nicht verfügbar ist."
fi
echo

# --------------------------------------------------
# sensors-detect ausführen
# --------------------------------------------------
if command -v sensors-detect >/dev/null 2>&1; then
    echo "Sensor-Erkennung für lm_sensors / CoolerControl"
    read -r -p "sensors-detect jetzt ausführen? [y/N]: " reply
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
        sudo sensors-detect
    fi
else
    echo "sensors-detect nicht gefunden."
fi
echo

# --------------------------------------------------
# libvirtd starten und aktivieren
# --------------------------------------------------
echo "libvirtd starten und beim Boot aktivieren"
read -r -p "Jetzt ausführen? [y/N]: " reply
if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
    sudo systemctl start libvirtd
    sudo systemctl enable libvirtd
fi
echo

# --------------------------------------------------
# Benutzer zur libvirt-Gruppe hinzufügen
# --------------------------------------------------
echo "Aktuellen Benutzer zur libvirt-Gruppe hinzufügen"
echo "Danach ist Ab- und wieder Anmelden nötig."
read -r -p "Jetzt ausführen? [y/N]: " reply
if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
    sudo usermod -aG libvirt "$USER"
    echo "Benutzer wurde zu libvirt hinzugefügt."
    echo "Bitte später einmal ab- und wieder anmelden."
fi
echo

# --------------------------------------------------
# coolercontrold bei Fehler automatisch neu starten
# Wenn der Daemon innerhalb von 60 Sekunden fünf
# Mal neu gestartet wird, bleibt er dauerhaft aus
# Ansonsten wird bei Fehlern neu gestartet
# Status kann mit
# $ systemctl show coolercontrold -p NRestarts -p ActiveState -p SubState
# die Anzahl Neustarts gezählt werden
# --------------------------------------------------
echo "Automatischen Neustart für coolercontrold bei Fehler aktivieren"
read -r -p "Jetzt einrichten? [y/N]: " reply
if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
    sudo mkdir -p /etc/systemd/system/coolercontrold.service.d

    sudo tee /etc/systemd/system/coolercontrold.service.d/restart.conf >/dev/null <<'EOF'
[Service]
Restart=on-failure
RestartSec=5

[Unit]
StartLimitIntervalSec=60
StartLimitBurst=5
EOF

    sudo systemctl daemon-reload
    sudo systemctl restart coolercontrold

    echo "Automatischer Neustart für coolercontrold wurde aktiviert."
fi
echo


echo "========================================"
echo "Setup abgeschlossen."
echo "========================================"
