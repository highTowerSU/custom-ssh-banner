```markdown
# Custom SSH Banner Script

This script generates a custom SSH banner using `figlet`. It loads configuration from `/etc/ssh/custom_sshd_banner.conf`, where you can set the admin contact email and warning message. The banner is saved in `/srv/ssh/banner`, and recommended `sshd_config` settings are displayed.

## Installation

### Option 1: Install via Git

1. Clone the repository:
   ```bash
   git clone https://github.com/highTowerSU/custom-ssh-banner.git
   cd custom-ssh-banner
   ```

2. Run the install script:
   ```bash
   sudo ./install.sh [--noninteractive] [--cron] [--runnow] [--modify-sshd-conf] [--mail <a@b.de>] [--warning <CAVE>]
   ```

### Option 2: One-Line Web Install

Run this command to download and execute the install script directly (options from install sh working). You can install this via the command-line with either curl, wget or another similar tool.

#### curl
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/highTowerSU/custom-ssh-banner/main/webinstall.sh)" "" [--noninteractive] [--cron] [--runnow] [--modify-sshd-conf] [--mail <a@b.de>] [--warning <CAVE>]
   ```

#### wget
   ```bash
   sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" [--noninteractive] [--cron] [--runnow] [--modify-sshd-conf] [--mail <a@b.de>] [--warning <CAVE>]
   ```

#### fetch
   ```bash
   sh -c "$(fetch -o - https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" [--noninteractive] [--cron] [--runnow] [--modify-sshd-conf] [--mail <a@b.de>] [--warning <CAVE>]
   ```





## Configuration

Edit `/etc/ssh/custom_sshd_banner.conf` to customize the admin contact email.
