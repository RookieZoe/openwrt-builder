#!/bin/bash
set -e

WORK_DIR=$(
  cd "$(dirname "$0")"
  cd ../
  pwd
)

PACK_TARGET=$1
GITHUB_WORKSPACE=${GITHUB_WORKSPACE:-$WORK_DIR}

TARGET_DIR="$GITHUB_WORKSPACE/openwrt/bin/targets/"
OP_TARGET_NAME=openwrt-x86-64-generic-squashfs-combined.img.gz

OUT_DIR="$GITHUB_WORKSPACE/out/"
OP_OUT_NAME=openwrt-x86-64-generic-squashfs-combined.img.gz
OP_OUT_TARBALL=openwrt-x86-64-generic_packages.tar.gz

case "$PACK_TARGET" in
'x64-samba4')
  OP_TARGET_NAME=openwrt-x86-64-generic-squashfs-combined.img.gz
  OP_OUT_NAME=openwrt-x86-64-generic-squashfs-combined_samba4.img.gz
  OP_OUT_TARBALL=openwrt-x86-64-generic_packages_samba4.tar.gz
  ;;
'aarch64')
  OP_TARGET_NAME=openwrt-armvirt-64-default-rootfs.tar.gz
  OP_OUT_NAME=openwrt-armvirt-64-default-rootfs.tar.gz
  OP_OUT_TARBALL=openwrt-armvirt-64-default_packages.tar.gz
  ;;
esac

mkdir -p "$OUT_DIR"
find "$TARGET_DIR" -follow -type f -name "$OP_TARGET_NAME" -print | while read -r file; do
  mv -f "$file" "$OUT_DIR/$OP_OUT_NAME"
  pushd "$(dirname "$file")" && tar -zcvf "$OUT_DIR/$OP_OUT_TARBALL" ./ || exit
  popd || exit
done
