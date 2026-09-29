#!/usr/bin/env bash

set -euo pipefail

config_file=${1:-.config}
test -f "$config_file"

# 删除旧值再追加，保证脚本重复执行时配置保持一致。
sed -i \
  -e '/^CONFIG_TARGET_OPTIMIZATION=/d' \
  -e '/^CONFIG_TARGET_ROOTFS_EXT4FS=/d' \
  -e '/^# CONFIG_TARGET_ROOTFS_EXT4FS is not set$/d' \
  -e '/^CONFIG_TARGET_ROOTFS_SQUASHFS=/d' \
  -e '/^# CONFIG_TARGET_ROOTFS_SQUASHFS is not set$/d' \
  -e '/^CONFIG_TARGET_ROOTFS_PARTSIZE=/d' \
  -e '/^CONFIG_KERNEL_BUILD_USER=/d' \
  -e '/^CONFIG_KERNEL_BUILD_DOMAIN=/d' \
  -e '/^CONFIG_GRUB_TITLE=/d' \
  -e '/^CONFIG_GRUB_TIMEOUT=/d' \
  "$config_file"

cat >> "$config_file" <<'EOF'
CONFIG_TARGET_OPTIMIZATION="-O2 -pipe"
CONFIG_TARGET_ROOTFS_EXT4FS=y
# CONFIG_TARGET_ROOTFS_SQUASHFS is not set
CONFIG_TARGET_ROOTFS_PARTSIZE=1024
CONFIG_KERNEL_BUILD_USER="GithubAction"
CONFIG_KERNEL_BUILD_DOMAIN="Ubuntu"
CONFIG_GRUB_TITLE="My-Router"
CONFIG_GRUB_TIMEOUT="1"
EOF
