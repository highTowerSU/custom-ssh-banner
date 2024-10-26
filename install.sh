#!/bin/bash
# -----------------------------------------------------------------------------
# install.sh
# Copyright (C) 2023 highTowerSU
#
# Repository: https://github.com/highTowerSU/custom-ssh-banner
#
# Description: installs custom ssh banner script
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


# Pfade für die Installation
SCRIPT_PATH="/usr/local/bin/generate_banner.sh"
CONFIG_PATH="/etc/ssh/custom_sshd_banner.conf"
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

# Abfrage, ob der Symlink erstellt werden soll
echo -n "Do you want to create a symlink for daily cron? (y/n): "
read create_symlink
if [[ "$create_symlink" == "y" || "$create_symlink" == "Y" ]]; then
    echo "Creating symlink at $SYMLINK_PATH..."
    ln -sf "$SCRIPT_PATH" "$SYMLINK_PATH"
    echo "Symlink created."
else
    echo "Symlink creation skipped."
fi

echo "Installation complete. Run $SCRIPT_PATH to generate the SSH banner."
