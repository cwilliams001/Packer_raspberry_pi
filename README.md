

# Raspberry Pi Image Builder with Packer and Docker

This project uses Packer and Docker to create custom Raspberry Pi images with additional provisioning like adding scripts that run at boot.

## Prerequisites

To run the scripts and build a custom image, you'll need:

- Docker installed on your local machine.
- Packer Builder ARM Docker image (mkaczanowski/packer-builder-arm)

## Provisioning Scripts

This project contains two provisioning scripts:

- `provision-pi.sh`: This script prepares the Raspberry Pi image with some general settings and software updates. It is responsible for:
  - Enabling SSH on the Raspberry Pi.
  - Setting a temporary password for the 'pi' user.
  - Enabling zswap with default settings.
  - Forcing automatic rootfs expansion on the first boot.
  - Updating the System.
  
- `zerotier-setup.sh`: This script installs and sets up ZeroTier on the Raspberry Pi. It is responsible for:
  - Checking if ZeroTier is installed and if not, it installs it.
  - Joining the ZeroTier network.
  - Enabling the ZeroTier service at boot.
  - Waiting for the ZeroTier network interface to become active.
  - Finally, it prompts you to accept the new device in the ZeroTier web console.

If you wish to change any settings, you can modify these scripts accordingly. For instance, you can add additional packages to be installed in the `provision-pi.sh` script, or you can replace `YOUR_NETWORK_ID_HERE` in the `zerotier-setup.sh` script with your actual ZeroTier network ID.

---

These explanations should give users a good understanding of what the scripts do and how they can modify them for their own needs.

## Building the Image

Run the following command to build the image:

```bash
docker run --rm -it --privileged -v /dev:/dev -v ${PWD}:/build mkaczanowski/packer-builder-arm:latest build raspbian.pkr.hcl
```

This command does the following:

- `--rm`: Automatically remove the container when it exits
- `-it`: Keep STDIN open even if not attached and allocate a pseudo-TTY, this makes it possible to have an interactive shell session
- `--privileged`: Give extended privileges to the Docker container, this is needed to perform operations like mount and umount
- `-v /dev:/dev`: Bind mount /dev on your host into the Docker container, this allows the container to access the block devices of your host
- `-v ${PWD}:/build`: Bind mount your current working directory into the /build directory inside the container
- `mkaczanowski/packer-builder-arm:latest`: The Docker image to run
- `build raspbian.pkr.hcl`: The command to execute inside the Docker container

This command creates a custom Raspberry Pi image according to the specifications defined in `raspbian.pkr.hcl`.

## Checking the Output

Once the command finishes, you'll find your custom image in the current directory. You can flash this image onto an SD card for use in a Raspberry Pi.

