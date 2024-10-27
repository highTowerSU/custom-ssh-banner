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
NONINTERACTIVE=false
MODIFYSSHDCONF=false

# Configuration loading
source "$CONFIG_PATH"


# Hilfe anzeigen
function show_help {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help                Show this help message and exit"
    echo "  -b, --noninteractive      Run in non-interactive mode"
    echo "  -m, --modify-sshd-conf    Modify sshd_config"
    echo ""
    echo "Example:"
    echo "  $0 --noninteractive --modify-sshd-conf"
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
        -m|--modify-sshd-conf)
            MODIFYSSHDCONF=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

if [[ "$SCRIPT_NAME" == "generate_banner" ]]; then
    NONINTERACTIVE=true
fi

mkdir -p /srv/ssh
apt install -y figlet
hostname=$(hostname -s)
domain=$(hostname -d)

# Hostname holen und figlet-Ausgaben erstellen
output_mini=$(echo "$hostname" | figlet -cWf mini)
output_big=$(echo "$hostname" | figlet -cWf big)

# Zeilenanzahl der Ausgaben bestimmen
lines_one=$(echo A | figlet -cWf big | wc -l)
lines_big=$(echo "$output_big" | wc -l)



# Banner-Datei erstellen
echo "################################################################################" > /srv/ssh/banner
# Zeilenanzahl vergleichen und entsprechende Ausgabe wählen
if [ "$lines_big" -gt "$lines_one" ]; then
    echo "$output_mini" >> /srv/ssh/banner
else
    echo "$output_big" >> /srv/ssh/banner
fi
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

modify_sshd_config=false
# Abfrage zur Anpassung der sshd_config
if $MODIFYSSHDCONF; then
    echo "Running the sshd_config modification immediately..."
    modify_sshd_config=true
elif ! $NONINTERACTIVE; then
    echo "To apply the banner, the following settings are recommended in sshd_config:"
    echo "  Banner /srv/ssh/banner"
    echo "  DebianBanner no"

    echo -n "Do you want to modify sshd_config now? (y/n): "
    read modify_sshd
    if [[ "$modify_sshd" == "y" || "$modify_sshd" == "Y" ]]; then
        modify_sshd_config=true
    else
        echo "sshd_config modification skipped."
    fi
else
    echo "Non-interactive mode detected. Skipping sshd_config modification."
fi

if $modify_sshd_config; then
    # Backup der sshd_config anlegen
    BACKUP_PATH_N=$BACKUP_PATH
    while [ -f "$BACKUP_PATH_N" ]; do
        echo "Backup already exists at $BACKUP_PATH_N."
        BACKUP_PATH_N=$BACKUP_PATH$(date "+%s")
        echo "Trying $BACKUP_PATH_N."
    done
    echo "Creating a backup of sshd_config at $BACKUP_PATH_N..."
    cp "$SSHD_CONFIG" "$BACKUP_PATH_N"
    echo "Backup created at $BACKUP_PATH_N."
    sed -i '/^Banner/d' "$SSHD_CONFIG"
    sed -i '/^DebianBanner/d' "$SSHD_CONFIG"
    echo "Banner /srv/ssh/banner" >> "$SSHD_CONFIG"
    echo "DebianBanner no" >> "$SSHD_CONFIG"
    service sshd restart
fi
