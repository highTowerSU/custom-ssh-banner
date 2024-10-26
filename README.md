# Custom SSH Banner Script

This script generates a custom SSH banner using `figlet`. It loads configuration from `/etc/ssh/custom_sshd_banner.conf`, where you can set the admin contact email. The banner is saved in `/srv/ssh/banner`, and recommended `sshd_config` settings are displayed.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/highTowerSU/custom-ssh-banner.git
   cd custom-ssh-banner
   ```

2. Run the banner generation script:
   ```bash
   sudo ./generate_banner.sh
   ```

3. The script will offer to apply recommended changes to `/etc/ssh/sshd_config`.

## Configuration

Edit `/etc/ssh/custom_sshd_banner.conf` to customize the admin contact email.
