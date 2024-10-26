#!/bin/bash

# Pfade für die Installation
SCRIPT_PATH="/usr/local/bin/generate_banner.sh"
CONFIG_PATH="/etc/ssh/custom_sshd_banner.conf"

# Skript kopieren und ausführbar machen
echo "Installing banner generation script to $SCRIPT_PATH..."
cp generate_banner.sh "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

# Konfigurationsdatei erstellen, falls sie nicht existiert
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Creating configuration file at $CONFIG_PATH..."
    cat << EOF > "$CONFIG_PATH"
# Default admin email for banner
ADMIN_EMAIL="root@$(hostname -f)"
EOF
    echo "Configuration file created at $CONFIG_PATH."
else
    echo "Configuration file already exists at $CONFIG_PATH. Skipping creation."
fi

echo "Installation complete. Run $SCRIPT_PATH to generate the SSH banner."
