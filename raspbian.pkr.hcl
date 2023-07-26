source "arm" "raspbian"{
file_urls = ["https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64.img.xz"]
file_checksum_url = "https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64.img.xz.sha256"
file_checksum_type = "sha256"
file_target_extension = "xz"
file_unarchive_cmd = ["xz", "-d", "$ARCHIVE_PATH"]
image_build_method = "reuse"
image_path = "raspian.img"
image_size = "4G"
image_type = "dos"

image_partitions {
    filesystem = "fat"
    start_sector = "8192"
    mountpoint = "/boot"
    name = "boot"
    size = "256M"
    type = "c"   
}

image_partitions {
    name = "root"
    type = "83"
    start_sector = "532480"
    filesystem = "ext4"
    size = "0"
    mountpoint = "/"
 }


image_chroot_env = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]
qemu_binary_source_path = "/usr/bin/qemu-aarch64-static"
qemu_binary_destination_path =  "/usr/bin/qemu-aarch64-static"

}

build {
  sources = ["source.arm.raspbian"]

  provisioner "file" {
    source      = "zerotier-setup.sh"
    destination = "/opt/"
  }

  provisioner "shell" {
    script = "provision-pi.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /opt/zerotier-setup.sh",
      "echo '@reboot sleep 60 && /opt/zerotier-setup.sh' >> mycron",
      "crontab mycron",
      "rm mycron"
    ]
  }
}