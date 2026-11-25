#!/bin/sh
set -eu

# pacman's download sandbox needs Landlock and setuid, which a container does not allow.
sed -i '/^\[options\]/a DisableSandbox' /etc/pacman.conf
pacman -Syu --noconfirm --needed git systemd-ukify bubblewrap dosfstools e2fsprogs mtools qemu-img

git init --quiet /opt/mkosi
git -C /opt/mkosi fetch --quiet --depth 1 https://github.com/systemd/mkosi.git "$MKOSI_COMMIT"
git -C /opt/mkosi checkout --quiet FETCH_HEAD
/opt/mkosi/bin/mkosi --force build

install -d out
qemu-img convert -f raw -O qcow2 mkosi.output/freebox-vm.raw out/freebox-vm.qcow2
