#!/bin/bash

# Überprüfen, ob git installiert ist
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Attempting to install..."
    if command -v apt &> /dev/null; then
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

# Installationsskript ausführen
chmod +x "$TEMP_DIR/install.sh"
cd $TEMP_DIR
"./install.sh" "$@"
cd ..

# Aufräumen
rm -rf "$TEMP_DIR"
