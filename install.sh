#!/bin/bash
# -----------------------------------------------------------------------------
# install.sh
# Copyright (C) 2023 highTowerSU
#
# Repository: https://github.com/highTowerSU/custom-ssh-banner
#
# Description: installs custom SSH banner script, supports optional cron setup 
#              and non-interactive mode.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# -----------------------------------------------------------------------------

# Standard-Parameter
NONINTERACTIVE=false
CRON=false
CONFIG_PATH="/etc/ssh/custom_sshd_banner.conf"

# Hilfe anzeigen
function show_help {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help                Show this help message and exit"
    echo "      --noninteractive      Run in non-interactive mode"
    echo "  -c, --cron                Set up a cron job for daily execution"
    echo ""
    echo "Example:"
    echo "  $0 --noninteractive --cron --config /path/to/custom.conf"
}

# Argumente parsen
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--noninteractive)
            NONINTERACTIVE=true
            shift
            ;;
        -c|--cron)
            CRON=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Pfade für die Installation
SCRIPT_PATH="/usr/local/bin/generate_banner.sh"
SYMLINK_PATH="/etc/cron.daily/generate_banner"

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

# Symlink für cron erstellen basierend auf NONINTERACTIVE oder Abfrage
create_symlink=false
if $CRON || $NONINTERACTIVE; then
    create_symlink=true
else
    echo -n "Do you want to create a symlink for daily cron? (y/n): "
    read create_symlink_response
    if [[ "$create_symlink_response" == "y" || "$create_symlink_response" == "Y" ]]; then
        create_symlink=true
    fi
fi

if $create_symlink; then
    echo "Creating symlink at $SYMLINK_PATH..."
    ln -sf "$SCRIPT_PATH" "$SYMLINK_PATH"
    echo "Symlink created."
else
    echo "Symlink creation skipped."
fi

echo "Installation complete. Run $SCRIPT_PATH to generate the SSH banner."
