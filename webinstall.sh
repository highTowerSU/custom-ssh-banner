#!/bin/bash

# Überprüfen, ob git installiert ist
if ! command -v git > /dev/null; then
    echo "Git is not installed. Attempting to install..."
    if command -v apt > /dev/null; then
        sudo apt update
        sudo apt install -y git
    else
        echo "Error: Package manager not supported or git could not be installed."
        exit 1
    fi
fi

# Temporäres Verzeichnis erstellen und Repository klonen
TEMP_DIR=$(mktemp -d)
git clone https://github.com/highTowerSU/custom-ssh-banner.git "$TEMP_DIR"

# Sicherstellen, dass install.sh existiert und ausführbar ist
if [ -f "$TEMP_DIR/install.sh" ]; then
    chmod +x "$TEMP_DIR/install.sh"
    cd $TEMP_DIR
    "./install.sh" "$@"
    cd ..
else
    echo "Error: install.sh not found in the repository."
    exit 1
fi

# Aufräumen
rm -rf "$TEMP_DIR"
