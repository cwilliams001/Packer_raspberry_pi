
# Raspberry Pi Image Builder with Packer and Docker

Create custom Raspberry Pi images with additional provisioning using Packer and Docker. This project contains configurations for setting up WireGuard, ZeroTier, or Tailscale on a Raspberry Pi.

## Features
- WireGuard Configuration (rpi-wireguard): Sets up a Raspberry Pi with WireGuard for secure VPN access.
- ZeroTier Configuration (rpi-zerotier): Sets up a Raspberry Pi with ZeroTier for network connectivity.
- Tailscale Configuration (rpi-tailscale): Sets up a Raspberry Pi with Tailscale for network connectivity.

## Prerequisites

To run the scripts and build a custom image, you'll need:
- Docker installed on your local machine.
- Packer Builder ARM Docker image (`mkaczanowski/packer-builder-arm`)

## Usage

### Configuration
1. **`config.pkrvars.hcl` (per configuration folder)**: Modify this file to include necessary configuration details. For example, in the `rpi-wireguard` folder, it contains the APN name.
   ```hcl
   apn_name = "your APN name"
   ```

## Provisioning Scripts

Each configuration folder contains provisioning scripts specific to the setup:

**Important:** Create new user and replace in provision-pi.sh script (replace 'newuser' and 'your-password-hash' with your desired username and password hash)
 Generate a hash for a password using the following command `openssl passwd -6 your-password-here`
 Use "\" to escape the "$" in the password hash

### rpi-wireguard
- `provision-pi.sh`: This script prepares the Raspberry Pi image with general settings, user setup, locale, and necessary applications. 
- `cell-hat-setup.sh`: This script configures the cell hat using AT commands. 
- `raspbian.pkr.hcl`: This is the Packer configuration file that orchestrates the build process, provisioning, and produces the custom Raspberry Pi image.

### rpi-zerotier
- `provision-pi.sh`: This script prepares the Raspberry Pi image with general settings, user setup, locale, and installs necessary applications including WireGuard.
- `zerotier-setup.sh`: This script installs ZeroTier, joins a specified ZeroTier network, and sets up ZeroTier to connect on boot.
- `cell-hat-setup.sh`: Configures the cell hat using AT commands.
- `raspbian.pkr.hcl`: This is the Packer configuration file that orchestrates the build process, provisioning, and produces the custom Raspberry Pi image.

### Configuration for rpi-zerotier
1. **`config.pkrvars.hcl`**: This file holds the ZeroTier network ID and APN name. Replace the placeholders with your actual details.
   ```hcl
   zerotier_network_id = "your_zerotier_network_id"
   apn_name = "your APN name"
   ```
   In `provision-pi.sh`, several system settings are configured including SSH, user creation, zswap, rootfs expansion, and more. It also sets up systemd service files for ZeroTier and cell-hat-setup. The `zerotier-setup.sh` script checks if ZeroTier is installed, if not, it installs it, then joins the specified ZeroTier network, and waits for the network interface to become active.

### rpi-tailscale
- `provision-pi.sh`: Prepares the Raspberry Pi image with general settings, user setup, locale, and installs necessary applications including Tailscale and WireGuard.
- `cell-hat-setup.sh`: Configures the cell hat using AT commands.
- `raspbian.pkr.hcl`: This is the Packer configuration file that orchestrates the build process, provisioning, and produces the custom Raspberry Pi image.

### Configuration for rpi-tailscale
1. **`config.pkrvars.hcl`**: This file holds the Tailscale authentication key and APN name. Be sure to replace the placeholders with your actual details.
   ```hcl
   tailscale_auth_key = "your tailscale auth key"
   apn_name = "your APN name"
   ```
   The `provision-pi.sh` script in this configuration installs Tailscale and sets it up to connect on boot using a systemd service. It also installs WireGuard as Tailscale is built on top of it. The `cell-hat-setup.sh` script is identical to the one in the rpi-wireguard configuration, which sets up cellular connectivity.
---

## Building the Image

1. Navigate to the configuration folder of your choice (e.g., `rpi-wireguard`).
2. Run the following command to build the image:

```bash
docker run --rm -it --privileged -v /dev:/dev -v ${PWD}:/build mkaczanowski/packer-builder-arm:latest build var-file=config.pkrvars.hcl raspbian.pkr.hcl
```

This command does the following:
- `--rm`: Automatically remove the container when it exits.
- `-it`: Keep STDIN open even if not attached and allocate a pseudo-TTY, this makes it possible to have an interactive shell session.
- `--privileged`: Give extended privileges to the Docker container, this is needed to perform operations like mount and umount.
- `-v /dev:/dev`: Bind mount /dev on your host into the Docker container, this allows the container to access the block devices of your host.
- `-v ${PWD}:/build`: Bind mount your current working directory into the /build directory inside the container.
- `mkaczanowski/packer-builder-arm:latest`: The Docker image to run.
- `var-file=config.pkrvars.hcl`: Tells Packer to use the configuration variables defined in `config.pkrvars.hcl
- `build raspbian.pkr.hcl`: The command to execute inside the Docker container.

This command creates a custom Raspberry Pi image according to the specifications defined in `raspbian.pkr.hcl`.

## Checking the Output

Once the command finishes, you'll find your custom image in the current directory. You can flash this image onto an SD card for use in a Raspberry Pi.
