#!/usr/bin/env bash
set -euo pipefail

NAME="$1"
RAM=${RAM:-2048}
CPU=${CPU:-2}
DISK_SIZE=${DISK_SIZE:-10}
IMAGE_DIR="/var/lib/libvirt/images"
IMAGE_NAME="debian-cloud.qcow2"
CLOUD_INIT_DIR="$(dirname "$0")/cloud-init"

if [ -z "$NAME" ]; then
  echo "Usage: $0 <vm-name>"
  exit 1
fi

IMG_PATH="$IMAGE_DIR/${NAME}.qcow2"
cp "$IMAGE_DIR/$IMAGE_NAME" "$IMG_PATH"
qemu-img resize "$IMG_PATH" ${DISK_SIZE}G || true

CLOUD_ISO="$IMAGE_DIR/${NAME}-cloud-init.iso"
cloud-localds -v "$CLOUD_ISO" "$CLOUD_INIT_DIR/user-data" --meta-data="$CLOUD_INIT_DIR/meta-data"

virt-install   --name "$NAME"   --ram "$RAM"   --vcpus "$CPU"   --disk path="$IMG_PATH",format=qcow2   --disk path="$CLOUD_ISO",device=cdrom   --import   --os-type=linux --os-variant=debian11   --graphics vnc,port=-1,listen=0.0.0.0   --noautoconsole

echo "VM $NAME created"
