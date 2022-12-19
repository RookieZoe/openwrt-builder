#!/bin/bash
set -e

WORK_DIR=$(
  cd "$(dirname "$0")"
  cd ../
  pwd
)

BUILD_TARGET=$1
REBUILD_FLAG=$2

GITHUB_WORKSPACE=${GITHUB_WORKSPACE:-$WORK_DIR}

R_VERSION=$(date +'v%y.%m.%d')
R_DESCRIPTION="OpenWrt $R_VERSION Build by Rookie_Zoe"
OPENWRT_SOURCE="https://github.com/Lienol/openwrt.git"
OPENWRT_BRANCH="master"

case "$BUILD_TARGET" in
'x64-samba4')
  OPENWRT_BRANCH="21.02"
  ;;
'aarch64')
  OPENWRT_BRANCH="master"
  ;;
esac

PUB_CONF_PATH="$GITHUB_WORKSPACE/public"
ARCH_CONF_PATH="$GITHUB_WORKSPACE/configs"

prepare_codes_feeds() {
  # pull openwrt source code
  rm -rf "$GITHUB_WORKSPACE/openwrt"
  git clone -b "$OPENWRT_BRANCH" --single-branch "$OPENWRT_SOURCE" "$GITHUB_WORKSPACE/openwrt"

  # replace luci:21.02 with luci:17.01-dev
  sed -i -e '/openwrt-luci.git;/d' "$GITHUB_WORKSPACE/openwrt/feeds.conf.default"
  {
    echo ""
    echo "src-git luci https://github.com/Lienol/openwrt-luci.git;21.02"
    echo "src-git diy1 https://github.com/xiaorouji/openwrt-passwall.git;packages"
    echo "src-git diy2 https://github.com/xiaorouji/openwrt-passwall.git;luci"
    echo "src-git amlogic https://github.com/ophub/luci-app-amlogic.git;main"
  } >>"$GITHUB_WORKSPACE/openwrt/feeds.conf.default"

  # replace release info
  {
    cat "$PUB_CONF_PATH/zzz-default-settings"
    echo "echo \"BUILD_ID=$R_VERSION\" >> /usr/lib/os-release"
    echo "echo \"DISTRIB_REVISION='$R_VERSION'\" >> /etc/openwrt_release"
    echo "echo \"DISTRIB_DESCRIPTION='$R_DESCRIPTION'\" >> /etc/openwrt_release"
    echo "exit 0"
  } >"$GITHUB_WORKSPACE/openwrt/package/default-settings/files/zzz-default-settings"

  cd "$GITHUB_WORKSPACE/openwrt/"

  # feeds update
  ./scripts/feeds update -a

  # replace feeds/packages/net/xray-core with feeds/diy1/xray-core
  rm -rf feeds/packages/net/xray-core
  cp -r feeds/diy1/xray-core feeds/packages/net

  # fix luci modal pannel style issue
  LUCI_HEADER_FILE="$GITHUB_WORKSPACE/openwrt/feeds/luci/modules/luci-base/luasrc/view/header.htm"
  LUCI_HEADER_STYLE_BEGIN=$(cat "$LUCI_HEADER_FILE" | grep -n "<style>" | awk -F ":" '{print $1}')
  LUCI_HEADER_STYLE_END=$(cat "$LUCI_HEADER_FILE" | grep -n "</style>" | awk -F ":" '{print $1}')
  sed -i ${LUCI_HEADER_STYLE_BEGIN},${LUCI_HEADER_STYLE_END}d "$LUCI_HEADER_FILE"

  # fix some luci-theme-bootstrap style issue
  LUCI_THEME_BOOTSTRAP_FILE="$GITHUB_WORKSPACE/openwrt/feeds/luci/themes/luci-theme-bootstrap/htdocs/luci-static/bootstrap/cascade.css"
  sed -i 's/940px/1100px/g' "$LUCI_THEME_BOOTSTRAP_FILE"
  cat "$PUB_CONF_PATH/luci-theme-bootstrap/cascade.css" >>"$LUCI_THEME_BOOTSTRAP_FILE"

  # make luci-app-ttyd height fit window
  LUCI_TTYD_TERMJS="$GITHUB_WORKSPACE/openwrt/feeds/luci/applications/luci-app-ttyd/htdocs/luci-static/resources/view/ttyd/term.js"
  sed -i 's/500px/calc(100vh - 173px)/g' "$LUCI_TTYD_TERMJS"

  # set luci-app-passwall rules
  TARGET_PASSWALL_CONFIG="$GITHUB_WORKSPACE/openwrt/feeds/diy2/luci-app-passwall/root/usr/share/passwall/"
  cat "$PUB_CONF_PATH/pw-rules/0_default_config" >"$TARGET_PASSWALL_CONFIG/0_default_config"
  cat "$PUB_CONF_PATH/pw-rules/block_host" >"$TARGET_PASSWALL_CONFIG/rules/block_host"
  cat "$PUB_CONF_PATH/pw-rules/block_ip" >"$TARGET_PASSWALL_CONFIG/rules/block_ip"
  cat "$PUB_CONF_PATH/pw-rules/direct_host" >"$TARGET_PASSWALL_CONFIG/rules/direct_host"
  cat "$PUB_CONF_PATH/pw-rules/direct_ip" >"$TARGET_PASSWALL_CONFIG/rules/direct_ip"
  cat "$PUB_CONF_PATH/pw-rules/lanlist_ipv4" >"$TARGET_PASSWALL_CONFIG/rules/lanlist_ipv4"
  cat "$PUB_CONF_PATH/pw-rules/lanlist_ipv6" >"$TARGET_PASSWALL_CONFIG/rules/lanlist_ipv6"
  cat "$PUB_CONF_PATH/pw-rules/proxy_host" >"$TARGET_PASSWALL_CONFIG/rules/proxy_host"
  cat "$PUB_CONF_PATH/pw-rules/proxy_ip" >"$TARGET_PASSWALL_CONFIG/rules/proxy_ip"

  # feeds install
  ./scripts/feeds install -a
}

prepare_configs() {
  cd "$GITHUB_WORKSPACE"
  git checkout ./

  cd "$GITHUB_WORKSPACE/openwrt/"
  rm -rf "$GITHUB_WORKSPACE/openwrt/bin/targets/"
  rm -f "$GITHUB_WORKSPACE/openwrt/.config"
  rm -f "$GITHUB_WORKSPACE/openwrt/.config.old"

  echo "Read config $1 > $GITHUB_WORKSPACE/openwrt/.config"
  cat "$1" >"$GITHUB_WORKSPACE/openwrt/.config"
  {
    cat "$PUB_CONF_PATH/release-info.config"
    echo ""
    echo "CONFIG_VERSION_NUMBER=\"$(date +'v%y.%m.%d')\""
    echo ""
  } >>"$GITHUB_WORKSPACE/openwrt/.config"

  make defconfig
  make download -j $(($(nproc) + 1)) V=s
}

echo "GITHUB_WORKSPACE=$GITHUB_WORKSPACE"

ARCH_CONF_FILE="$ARCH_CONF_PATH/x64.config"
case "$BUILD_TARGET" in
'x64-samba4')
  ARCH_CONF_FILE="$ARCH_CONF_PATH/x64_samba.config"
  ;;
'aarch64')
  ARCH_CONF_FILE="$ARCH_CONF_PATH/arm8.config"
  ;;
esac

if [ -z "$ARCH_CONF_FILE" ]; then
  echo "ARCH_CONF_FILE not provide"
  exit 1
fi

echo "ARCH_CONF_FILE=$ARCH_CONF_FILE"

if [ "$REBUILD_FLAG" != "REBUILD" ]; then
  prepare_codes_feeds
fi

prepare_configs "$ARCH_CONF_FILE"

exit 0
