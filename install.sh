#!/bin/bash

# -----------------------------------------------------------------------------
# install.sh
# Copyright (C) 2010-2024 highTowerSU
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
RUNNOW=false
CRON=false
MODIFYSSHDCONF=false
#WARNING_MESSAGE=false
#MAIL_ADDRESS=false

CONFIG_PATH="/etc/ssh/custom_sshd_banner.conf"
SCRIPT_PATH="/usr/local/bin/generate_banner.sh"
SYMLINK_PATH="/etc/cron.daily/generate_banner"

# Hilfe anzeigen
function show_help {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help                Show this help message and exit"
    echo "  -a, --mail <a@b.de>       Set mail address in config"
    echo "  -d, --cron                Set up a cron job for daily execution"
    echo "  -m, --modify-sshd-conf    Modify sshd_config when used with --runnow"
    echo "  -n, --noninteractive      Run in non-interactive mode"
    echo "  -r, --runnow              Run the script immediately after installation"
    echo "  -w, --warning <CAVE>      Set warning message in config"
    echo ""
    echo "Example:"
    echo "  $0 --noninteractive --cron --runnow --modify-sshd-conf"
}

# Argumente parsen
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -a|--mail)
            MAIL_ADDRESS="$2"
            shift 2
            ;;
        -c|--cron)
            CRON=true
            shift
            ;;
        -m|--modify-sshd-conf)
            MODIFYSSHDCONF=true
            shift
            ;;
        -n|--noninteractive)
            NONINTERACTIVE=true
            echo "switched to noninteractive-Mode"
            shift
            ;;
        -r|--runnow)
            RUNNOW=true
            shift
            ;;
        -w|--warning)
            WARNING_MESSAGE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done


# Skript kopieren und ausführbar machen
echo "Installing banner generation script to $SCRIPT_PATH..."
cp generate_banner.sh "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

# Konfigurationsdatei erstellen, falls sie nicht existiert
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Creating configuration file at $CONFIG_PATH..."
    cat << EOF > "$CONFIG_PATH"
# Default admin email for banner
ADMIN_EMAIL="${MAIL_ADDRESS:-root@$(hostname -f)}"
EOF
    # Warnmeldung hinzufügen, falls gesetzt
    if [ -n "$WARNING_MESSAGE" ]; then
        echo "WARNING_MESSAGE=\"$WARNING_MESSAGE\"" >> "$CONFIG_PATH"
    fi
    echo "Configuration file created at $CONFIG_PATH."
else
    echo "Configuration file already exists at $CONFIG_PATH. Skipping creation."
fi
echo "Copying configuration template to ${CONFIG_FILE}.dist..."
cp custom_sshd_banner.conf "${CONFIG_PATH}.dist"

# Symlink für cron erstellen basierend auf NONINTERACTIVE oder Abfrage
create_symlink=false
if $CRON; then
    create_symlink=true
elif ! $NONINTERACTIVE; then
    echo -n "Do you want to create a symlink for daily cron? (y/N): "
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

ARGS=()
if $NONINTERACTIVE; then
    ARGS+=("--noninteractive")
fi
if $MODIFYSSHDCONF; then
    ARGS+=("--modify-sshd-conf")
fi

# Sofortige Ausführung basierend auf --runnow oder interaktive Abfrage
if $RUNNOW; then
    echo "Running the banner generation script immediately..."
    echo "Argumente: ${ARGS[@]}"
    "$SCRIPT_PATH" ${ARGS[@]}
elif ! $NONINTERACTIVE; then
    echo -n "Do you want to run the banner generation script immediately? (y/N): "
    read runnow_response
    if [[ "$runnow_response" == "y" || "$runnow_response" == "Y" ]]; then
        echo "Running the banner generation script immediately..."
        echo "Argumente: ${ARGS[@]}"
        "$SCRIPT_PATH" ${ARGS[@]}
    else
        echo "Immediate run skipped."
    fi
fi
