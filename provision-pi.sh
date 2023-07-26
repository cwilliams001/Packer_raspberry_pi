#!/bin/bash

# enable SSH
touch /boot/ssh

# add temporary password
echo 'pi:pi' | chpasswd

# enable zswap with default settings
sed -i -e 's/$/ zswap.enabled=1/' /boot/cmdline.txt

# force automatic rootfs expansion on first boot:
# https://forums.raspberrypi.com/viewtopic.php?t=174434#p1117084
wget -O /etc/init.d/resize2fs_once https://raw.githubusercontent.com/RPi-Distro/pi-gen/master/stage2/01-sys-tweaks/files/resize2fs_once
chmod +x /etc/init.d/resize2fs_once
systemctl enable resize2fs_once

# Update the System
apt update && apt upgrade -y
