#!/usr/bin/env bash
set -euo pipefail

log() {
    echo
    echo "==> $1"
}

warn() {
    echo
    echo "WARN: $1"
}

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

require_cmd() {
    local cmd="$1"
    if ! has_cmd "$cmd"; then
        echo "Fehler: '$cmd' wurde nicht gefunden."
        exit 1
    fi
}

# -----------------------------
# Konfiguration
# -----------------------------

# Basis für C/C++/Rust/Python/Embedded
BASE_PACKAGES=(
    gcc
    gcc-c++
    clang
    clang-tools-extra
    binutils
    make
    cmake
    ninja-build
    pkgconf
    pkgconf-pkg-config
    gdb
    gdb-gdbserver
    git
    git-lfs
    strace
    ltrace
    perf
    podman
    openocd
    picocom
    dfu-util
    usbutils
    python3
    python3-pip
    openssh-clients
    curl
    valgrind
    ccache
    file
    unzip
)

PYTHON_PACKAGES=(
    numpy
    pandas
    matplotlib
)

# -----------------------------
# Start
# -----------------------------

log "Prüfe Voraussetzungen"
require_cmd dnf
require_cmd sudo

log "Aktualisiere Paket-Metadaten"
sudo dnf makecache -y

log "Installiere Basis-Pakete"
sudo dnf install -y "${BASE_PACKAGES[@]}"

log "Initialisiere git-lfs"
git lfs install || true

# Install Rust
if has_cmd rustup; then
    log "Rustup ist bereits installiert"
else
    log "Installiere rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

if [[ -f "$HOME/.cargo/env" ]]; then
    # Nur für die Laufzeit dieses Skripts laden,
    # keine Shell-Konfigurationsdateien ändern
    # shellcheck disable=SC1090
    source "$HOME/.cargo/env"
fi

if has_cmd rustup; then
    log "Installiere/aktualisiere Rust stable + Komponenten"
    rustup default stable
    rustup component add rustfmt clippy rust-src
else
    warn "rustup konnte nach der Installation nicht geladen werden."
    warn "Starte später: source ~/.cargo/env"
fi

log "Installiere Python-Pakete im User-Kontext"
python3 -m pip install --user --upgrade pip
python3 -m pip install --user "${PYTHON_PACKAGES[@]}"


log "Richte VS Code Repository ein"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo tee /etc/yum.repos.d/vscode.repo >/dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

    log "Installiere VS Code"
    sudo dnf install -y code

log "Versionen prüfen"
TOOLS_TO_CHECK=(
    gcc
    clang
    gdb
    cmake
    ninja
    git
    podman
    python3
    code
)

if has_cmd rustc; then
    TOOLS_TO_CHECK+=(rustc cargo)
fi

for tool in "${TOOLS_TO_CHECK[@]}"; do
    if has_cmd "$tool"; then
        echo "--- $tool ---"
        "$tool" --version | head -n 1 || true
    else
        warn "$tool wurde nicht gefunden"
    fi
done


log "Setup abgeschlossen"

cat <<'EOF'

==============================
WICHTIGE HINWEISE
==============================

Python (empfohlen: pro Projekt ein venv):

  python3 -m venv .venv
  source .venv/bin/activate

  # danach:
  pip install -U pip
  pip install <pakete>

  # arbeiten

  # verlassen:
  deactivate

ccache (optional nutzen):

  Manuell:
    ccache gcc main.c -o main

  Im Makefile:
    CC := ccache gcc
    CXX := ccache g++

Podman Socket (NICHT automatisch gestartet):

  Falls du ihn irgendwann brauchst:
    systemctl --user start podman.socket

Rust:

  Falls 'cargo' in einem neuen Terminal nicht gefunden wird:
    source ~/.cargo/env

VS Code:

  Wurde nativ installiert, nicht per Flatpak.
  Das ist für Embedded, Debugging und Toolchain-Zugriffe meist die bessere Wahl.

Wichtig:

- Keine ~/.bashrc wurde verändert
- Keine systemd-Services wurden aktiviert
- Das Skript ist erneut ausführbar
- Das VS Code Repo wird sauber gesetzt, nicht mehrfach angehängt

==============================

EOF
