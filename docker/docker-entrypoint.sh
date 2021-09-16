#!/bin/sh
set -e

CONF_DIR=${CONF_DIR:-}
LAN_ADDRESS=${LAN_ADDRESS:-}
LAN_NETMASK=${LAN_NETMASK:-}
LAN_GATEWAY=${LAN_GATEWAY:-}

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

data_persistence_folder() {
  local source_dir=$(dirname $1)
  local source_full=$(cd $1 && pwd)
  local target_dir=$(cd $CONF_DIR && pwd)
  local target_full=$target_dir$source_full

  if [ ! -h "${source_full}" ]; then
    if [ -e "${target_full}" ]; then
      # exists
      echo "set link [ "$source_full" ] to folder [ "$target_full" ]"
      rm -rf $source_full
      mkdir -p $source_dir
    else
      echo "transfer folder [ "$source_full" ] to [ "$target_full" ]"
      mkdir -p $(dirname $target_full)
      mv $source_full $(dirname $target_full)
    fi
    ln -sf $target_full $source_full
  fi
}

data_persistence_file() {
  local source_dir=$(dirname $1)
  local source_full=$1
  local target_dir=$(cd $CONF_DIR && pwd)
  local target_full=$target_dir$source_full

  if [ ! -h "${source_full}" ]; then
    if [ -e "${target_full}" ]; then
      # exists
      echo "set link [ "$source_full" ] to file [ "$target_full" ]"
      rm -rf $source_full
      mkdir -p $source_dir
    else
      echo "transfer file [ "$source_full" ] to [ "$target_full" ]"
      mkdir -p $(dirname $target_full)
      mv $source_full $(dirname $target_full)
    fi
    ln -sf $target_full $source_full
  fi
}

if [ -n "${LAN_ADDRESS:-}" ] && [ -n "${LAN_NETMASK:-}" ] && [ -n "${LAN_GATEWAY:-}" ]; then
  network_settings
fi

if [ -d "${CONF_DIR}" ] && [ -w "${CONF_DIR}" ]; then
  data_persistence_folder /root/
  data_persistence_folder /usr/share/

  ls -A /etc/ | while read -r file; do
    if [ $file != "hosts" ] && [ $file != "hostname" ] && [ $file != "resolv.conf" ] && [ $file != "openwrt_release" ]; then
      if [ -d "/etc/${file}" ] && [ -w "/etc/${file}" ]; then
        data_persistence_folder "/etc/"$file
      elif [ -f "/etc/${file}" ] && [ -w "/etc/${file}" ]; then
        data_persistence_file "/etc/"$file
      fi
    fi
  done
fi

exec "$@"
