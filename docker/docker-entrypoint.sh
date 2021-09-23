#!/bin/sh
set -e

CONF_DIR=${CONF_DIR:-}
LAN_ADDRESS=${LAN_ADDRESS:-}
LAN_NETMASK=${LAN_NETMASK:-}
LAN_GATEWAY=${LAN_GATEWAY:-}

reset_reversion() {
  echo "reset reversion..."
  rr_r_description="OpenWrt $R_VERSION Build by Rookie_Zoe"

  sed -i '/BUILD_ID=/d' /usr/lib/os-release
  sed -i '/DISTRIB_REVISION=/d' /etc/openwrt_release
  sed -i '/DISTRIB_DESCRIPTION=/d' /etc/openwrt_release

  echo "BUILD_ID=$R_VERSION" >>/usr/lib/os-release
  {
    echo "DISTRIB_REVISION='$R_VERSION'"
    echo "DISTRIB_DESCRIPTION='$rr_r_description'"
  } >>/etc/openwrt_release
}

network_settings() {
  echo "reset network..."
  # there is /etc/uci-defaults/99-default-settings
  # make sure network settings is after 99-default-settings
  {
    echo "uci set network.lan.proto='static'"
    echo "uci set network.lan.ipaddr='$LAN_ADDRESS'"
    echo "uci set network.lan.netmask='$LAN_NETMASK'"
    echo "uci set network.lan.gateway='$LAN_GATEWAY'"
    echo "uci commit network"
    echo "exit 0"
  } >/etc/uci-defaults/999-default-settings
}

persistence_data() {
  dp_source_full=""
  dp_path_type=""

  if [ -d "$1" ] && [ -w "$1" ]; then
    dp_source_full=$(cd "$1" && pwd)
    dp_path_type="folder"
  elif [ -f "$1" ] && [ -w "$1" ]; then
    dp_source_full="$1"
    dp_path_type="file"
  elif [ ! -e "$1" ]; then
    dp_source_full="$1"
    dp_path_type="not exists file/folder"
  fi

  dp_source_dir=$(dirname "$1")
  dp_target_dir=$(cd "$CONF_DIR" && pwd)
  dp_target_full=$dp_target_dir$dp_source_full

  if [ -e "$dp_target_full" ]; then
    echo "set link [ $dp_source_full ] to $dp_path_type [ $dp_target_full ]"
    rm -rf "$dp_source_full"
    mkdir -p "$dp_source_dir"
    ln -sf "$dp_target_full" "$dp_source_full"
  elif [ -e "$dp_source_full" ]; then
    echo "transfer [ $dp_source_full ] to $dp_path_type [ $dp_target_full ]"
    mkdir -p "$(dirname "$dp_target_full")"
    mv "$dp_source_full" "$(dirname "$dp_target_full")"
    ln -sf "$dp_target_full" "$dp_source_full"
  fi
}

persistence_paths() {
  echo "take the 'and set' of the two lists of files..."
  pl_target_dir=$(cd "$CONF_DIR" && pwd)
  persistence_list="/root\n"
  persistence_list="$persistence_list/usr/share/xray\n"
  persistence_list="$persistence_list/usr/share/passwall/rules\n"

  etc_exclude_names="banner.*\|hostname.*\|hosts.*\|luci.*\|modules.*\|openwrt_.*\|opkg.*\|preinit.*\|resolv.*\|uci.*\|vmware.*"

  # folders in /etc
  [ -e /etc ] && persistence_list="$persistence_list$(
    find /etc -maxdepth 1 \
      -type d -a ! -name "etc" -a \
      ! -regex ".*\($etc_exclude_names\)"
  )\n"

  # folders in /etc
  [ -e /etc ] && persistence_list="$persistence_list$(
    find /etc -maxdepth 1 \
      -type f -a ! -name "etc" -a \
      ! -regex ".*\($etc_exclude_names\)"
  )\n"

  # folders in $pl_target_dir/etc
  [ -e "$pl_target_dir/etc" ] && persistence_list="$persistence_list$(
    find "$pl_target_dir/etc" -maxdepth 1 \
      -type d -a ! -name "$(basename "$pl_target_dir/etc")" -a \
      ! -regex ".*\($etc_exclude_names\)" \
      -exec sh -c 'echo ${0#$1}' {} "$pl_target_dir" \;
  )\n"

  # files in $pl_target_dir/etc
  [ -e "$pl_target_dir/etc" ] && persistence_list="$persistence_list$(
    find "$pl_target_dir/etc" -maxdepth 1 \
      -type f -a ! -name "$(basename "$pl_target_dir/etc")" -a \
      ! -regex ".*\($etc_exclude_names\)" \
      -exec sh -c 'echo ${0#$1}' {} "$pl_target_dir" \;
  )\n"

  # shellcheck disable=SC2059
  printf "$persistence_list" | sort | uniq | while read -r file; do
    [ -n "$file" ] && persistence_data "$file"
  done
}

if [ -n "$R_VERSION" ]; then
  reset_reversion
fi

if [ -n "${LAN_ADDRESS:-}" ] && [ -n "${LAN_NETMASK:-}" ] && [ -n "${LAN_GATEWAY:-}" ]; then
  network_settings
fi

if [ -d "$CONF_DIR" ] && [ -w "$CONF_DIR" ]; then
  persistence_paths
fi

exec "$@"
