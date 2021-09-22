#!/bin/sh
set -e

CONF_DIR=${CONF_DIR:-}
LAN_ADDRESS=${LAN_ADDRESS:-}
LAN_NETMASK=${LAN_NETMASK:-}
LAN_GATEWAY=${LAN_GATEWAY:-}

reset_reversion() {
  local R_DESCRIPTION="OpenWrt "$R_VERSION" Build by Rookie_Zoe"
  sed -i '/BUILD_ID=/d' /usr/lib/os-release
  sed -i '/DISTRIB_REVISION=/d' /etc/openwrt_release
  sed -i '/DISTRIB_DESCRIPTION=/d' /etc/openwrt_release
  echo "BUILD_ID=\"$R_VERSION\"" >>/usr/lib/os-release
  echo "DISTRIB_REVISION='$R_VERSION'" >>/etc/openwrt_release
  echo "DISTRIB_DESCRIPTION='$R_DESCRIPTION'" >>/etc/openwrt_release
}

network_settings() {
  # there is /etc/uci-defaults/99-default-settings
  # make sure network settings is after 99-default-settings
  echo "uci set network.lan.proto='static'" >/etc/uci-defaults/999-default-settings
  echo "uci set network.lan.ipaddr='${LAN_ADDRESS}'" >>/etc/uci-defaults/999-default-settings
  echo "uci set network.lan.netmask='${LAN_NETMASK}'" >>/etc/uci-defaults/999-default-settings
  echo "uci set network.lan.gateway='${LAN_GATEWAY}'" >>/etc/uci-defaults/999-default-settings
  echo "uci commit network" >>/etc/uci-defaults/999-default-settings
  echo "exit 0" >>/etc/uci-defaults/999-default-settings
}

data_persistence() {
  local source_full
  local path_type

  if [ -d $1 ] && [ -w $1 ]; then
    source_full=$(cd $1 && pwd)
    path_type="folder"
  elif [ -f $1 ] && [ -w $1 ]; then
    source_full=$1
    path_type="file"
  # elif [ -h $1 ] && [ -w $1 ]; then
  #   source_full=$1
  #   path_type="link"
  fi

  local source_dir=$(dirname $1)
  local target_dir=$(cd $CONF_DIR && pwd)
  local target_full=$target_dir$source_full

  if [ ! -h "${source_full}" ]; then # /etc/bird
    if [ -e "${target_full}" ]; then # /data/etc/bird
      # exists
      echo "set link [ "$source_full" ] to "$path_type" [ "$target_full" ]"
      rm -rf $source_full
      mkdir -p $source_dir
    else
      echo "transfer [ "$source_full" ] to "$path_type" [ "$target_full" ]"
      mkdir -p $(dirname $target_full)
      mv $source_full $(dirname $target_full)
    fi
    ln -sf $target_full $source_full
  fi
}

if [ -n "${R_VERSION}" ]; then
  reset_reversion
fi

if [ -n "${LAN_ADDRESS:-}" ] && [ -n "${LAN_NETMASK:-}" ] && [ -n "${LAN_GATEWAY:-}" ]; then
  network_settings
fi

if [ -d "${CONF_DIR}" ] && [ -w "${CONF_DIR}" ]; then
  data_persistence /root/

  ls -A /usr/share/ | while read -r file; do
    case "$file" in
    passwall | xray)
      data_persistence "/usr/share/"$file
      ;;
    *)
      # skip
      ;;
    esac
  done

  ls -A /etc/ | while read -r file; do
    case "$file" in
    banner | hostname | hosts | openwrt_release | openwrt_version | preinit | resolv.conf)
      # skip
      ;;
    *)
      data_persistence "/etc/"$file
      ;;
    esac
  done
fi

exec "$@"
