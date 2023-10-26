#!/bin/bash
sleep 60
ZEROTIER_NETWORK_ID=$(cat /opt/source/zerotier_network_id.txt)
sleep 5
# Check if ZeroTier is installed
if ! command -v zerotier-cli >/dev/null 2>&1; then
  # Update package lists
  sudo apt-get update

  # Install ZeroTier
  curl -s https://install.zerotier.com | sudo bash
fi

# Join the ZeroTier network
sudo zerotier-cli join $ZEROTIER_NETWORK_ID

# Enable ZeroTier service at boot
sudo systemctl enable zerotier-one
sudo systemctl start zerotier-one

# Wait for the ZeroTier network interface to become active
while ! zerotier-cli listnetworks | grep -q "${ZEROTIER_NETWORK_ID}.*ACCESS_DENIED"; do
  sleep 1
done

# Accept the new device in the ZeroTier web console (https://my.zerotier.com/)

# Wait for the ZeroTier network interface to become active
while ! zerotier-cli listnetworks | grep -q "${ZEROTIER_NETWORK_ID}.*OK"; do
  sleep 1
done

echo "ZeroTier connected!"