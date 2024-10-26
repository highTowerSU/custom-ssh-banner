#!/bin/bash
# Configuration loading
source /etc/custom_ssh_banner.conf

mkdir -p /srv/ssh
apt install -y figlet
hostname=$(hostname -s)
domain=$(hostname -d)

# Banner-Datei erstellen
echo "################################################################################" > /srv/ssh/banner
echo $hostname | figlet -cWf big >> /srv/ssh/banner
echo $domain | figlet -cWf term >> /srv/ssh/banner
echo >> /srv/ssh/banner
echo "contact: $ADMIN_EMAIL" | figlet -cWf term >> /srv/ssh/banner
echo >> /srv/ssh/banner
echo "################################################################################" >> /srv/ssh/banner
echo >> /srv/ssh/banner
cat /srv/ssh/banner

echo "Recommended sshd_config changes:"
echo "Banner /srv/ssh/banner"
echo "DebianBanner no"

# Abfrage zur Anpassung der sshd_config
read -p "Apply changes to /etc/ssh/sshd_config for this banner? (y/n): " modify_sshd
if [[ "$modify_sshd" == "y" || "$modify_sshd" == "Y" ]]; then
    sed -i '/^Banner/d' /etc/ssh/sshd_config
    sed -i '/^DebianBanner/d' /etc/ssh/sshd_config
    echo "Banner /srv/ssh/banner" >> /etc/ssh/sshd_config
    echo "DebianBanner no" >> /etc/ssh/sshd_config
    service sshd restart
fi
