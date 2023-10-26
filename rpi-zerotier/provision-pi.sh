#!/bin/bash

# enable SSH
touch /boot/ssh

# Create new user (replace 'newuser' and 'your-password-hash' with your desired username and password hash)
# Generate a hash for a password using the following command "openssl passwd -6 your-password-here"
# Use "\" to escape the "$" in the password hash
useradd -m -s /bin/bash ots
echo "ots:\$6\$eWm4YyeNVc.LZTFK\$I4iZNZNKTLB9SUpLqDBMjVI5mumKD7bJL59mgIsXGjtkPkvhRSE1gdWiIGVjEz3Yl05IYK8yLcalHTXmt3ET10" | chpasswd -e
usermod -aG sudo ots

# Remove the first boot wizard user
userdel -r rpi-first-boot-wizard

# enable zswap with default settings
sed -i -e 's/$/ zswap.enabled=1/' /boot/cmdline.txt

# force automatic rootfs expansion on first boot:
# https://forums.raspberrypi.com/viewtopic.php?t=174434#p1117084
wget -O /etc/init.d/resize2fs_once https://raw.githubusercontent.com/RPi-Distro/pi-gen/master/stage2/01-sys-tweaks/files/resize2fs_once
chmod +x /etc/init.d/resize2fs_once
systemctl enable resize2fs_once

# Update the System
apt remove chromium-browser -y
apt update && apt upgrade -y
apt install chromium-browser -y

# Create systemd service file for ZeroTier
echo "[Unit]
Description=ZeroTier
After=network.target

[Service]
ExecStart=/bin/bash /opt/source/zerotier-setup.sh
Type=simple

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/zerotier.service

# Create systemd service file for cell-hat-setup

echo "[Unit]
Description=Cell Hat Setup
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash /opt/source/cell-hat-setup.sh
RemainAfterExit=yes
ExecStartPost=/bin/systemctl disable cell-hat-setup.service

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/cell-hat-setup.service


# Enable ZeroTier service at boot
systemctl enable zerotier
systemctl enable cell-hat-setup.service

# Skip initial setup wizard
echo "pi ALL=NOPASSWD: /usr/sbin/raspi-config, /sbin/shutdown" > /etc/sudoers.d/piwiz
rm /etc/xdg/autostart/piwiz.desktop

# Set up locale, keyboard layout, and timezone
raspi-config nonint do_change_locale en_US.UTF-8
raspi-config nonint do_configure_keyboard us
raspi-config nonint do_change_timezone America/New_York

# Auto login to command line (change to B4 for desktop auto-login)
raspi-config nonint do_boot_behaviour B4

# Install Applications
apt install vim minicom wireguard wireguard-tools -y

# Install and configure UFW
apt install ufw -y
ufw enable
ufw allow ssh

# SSH Hardening
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

# System cleanup
apt autoremove -y && apt clean
