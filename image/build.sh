#!/bin/sh
# Builds image/out/freebox-vm.qcow2: Arch Linux ARM with Docker, cloud-init and sshd, inside an arm64 container.
set -eu

builder_image=menci/archlinuxarm:base-devel-20261125.45559916999@sha256:9e8cfce64f47d82704eb1bf35e3ea49ba52c22e6300385d7e49c2d40d7d0a5d4
mkosi_commit=ecf7f5702bb2052b7a69cab3fe7d37bc3b9ad77b

cd "$(dirname "$0")"
# mkosi needs loop devices and mounts to assemble the disk.
docker run --rm --privileged --platform linux/arm64 \
  -v "$PWD:/work" -w /work \
  -e MKOSI_COMMIT="$mkosi_commit" \
  "$builder_image" /work/build-in-container.sh
