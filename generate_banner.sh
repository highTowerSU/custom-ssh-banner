#!/bin/bash

# -----------------------------------------------------------------------------
# generate_banner.sh
# Copyright (C) 2023 highTowerSU
#
# Repository: https://github.com/highTowerSU/custom-ssh-banner
#
# Description: This script generates a custom SSH banner using `figlet` to display 
# the hostname, domain, and contact email. The generated banner can be applied 
# to the SSH server by updating sshd_config. Configuration settings are loaded 
# from /etc/ssh/custom_sshd_banner.conf.
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

CONFIG_PATH="/etc/ssh/custom_sshd_banner.conf"
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_PATH="/etc/ssh/sshd_config.bak"
# Configuration loading
source "$CONFIG_PATH"

NONINTERACTIVE=false
if [[ "$1" == "--noninteractive" ]]; then
    NONINTERACTIVE=true
fi
if [[ "$SCRIPT_NAME" == "generate_banner" ]]; then
    NONINTERACTIVE=true
fi

mkdir -p /srv/ssh
apt install -y figlet
hostname=$(hostname -s)
domain=$(hostname -d)

# Banner-Datei erstellen
echo "################################################################################" > /srv/ssh/banner
echo $hostname | figlet -cWf mini >> /srv/ssh/banner
echo $domain | figlet -cWf term >> /srv/ssh/banner
echo >> /srv/ssh/banner
echo "contact: $ADMIN_EMAIL" | figlet -cWf term >> /srv/ssh/banner
if [[ -n "$WARNING_MESSAGE" ]]; then
    echo "$WARNING_MESSAGE" | figlet -cWf term >> /srv/ssh/banner
fi
echo >> /srv/ssh/banner
echo "################################################################################" >> /srv/ssh/banner
echo >> /srv/ssh/banner
cat /srv/ssh/banner

echo "Recommended sshd_config changes:"
echo "Banner /srv/ssh/banner"
echo "DebianBanner no"

# Abfrage zur Anpassung der sshd_config

if [ "$NONINTERACTIVE" == "true" ]; then
    echo "Non-interactive mode detected. Skipping sshd_config modification."
else
    echo "To apply the banner, the following settings are recommended in sshd_config:"
    echo "  Banner /srv/ssh/banner"
    echo "  DebianBanner no"

    echo -n "Do you want to modify sshd_config now? (y/n): "
    read modify_sshd
    if [[ "$modify_sshd" == "y" || "$modify_sshd" == "Y" ]]; then
        # Backup der sshd_config anlegen
        if [ ! -f "$BACKUP_PATH" ]; then
            echo "Creating a backup of sshd_config at $BACKUP_PATH..."
            cp "$SSHD_CONFIG" "$BACKUP_PATH"
            echo "Backup created at $BACKUP_PATH."
        else
            echo "Backup already exists at $BACKUP_PATH. Skipping backup."
        fi
        sed -i '/^Banner/d' "$SSHD_CONFIG"
        sed -i '/^DebianBanner/d' "$SSHD_CONFIG"
        echo "Banner /srv/ssh/banner" >> "$SSHD_CONFIG"
        echo "DebianBanner no" >> "$SSHD_CONFIG"
        service sshd restart
    else
        echo "sshd_config modification skipped."
    fi
fi

echo "Installation complete. Run $SCRIPT_PATH to generate the SSH banner."
