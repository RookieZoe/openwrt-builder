#!/bin/bash
set -e

WORK_DIR=$(
  cd "$(dirname "$0")"
  pwd
)

R_VERSION=$(date +'v%y.%m.%d')
R_DESCRIPTION="OpenWrt $R_VERSION Build by Rookie_Zoe"
GITHUB_WORKSPACE=${GITHUB_WORKSPACE:-$WORK_DIR}
OPENWRT_CONFIG_FILE=$1
REBUILD_FLAG=$2

prepare_codes_feeds() {
  # pull openwrt source code
  rm -rf "$GITHUB_WORKSPACE/openwrt"
  git clone -b 21.02 --single-branch https://github.com/Lienol/openwrt.git "$GITHUB_WORKSPACE/openwrt"

  # replace luci:21.02 with luci:19.07
  sed -i -e '/openwrt-luci.git;21.02/d' "$GITHUB_WORKSPACE/openwrt/feeds.conf.default"
  # add diy1
  {
    echo ""
    echo "src-git luci https://github.com/Lienol/openwrt-luci.git;19.07"
    echo "src-git diy1 https://github.com/xiaorouji/openwrt-passwall.git;main"
  } >>"$GITHUB_WORKSPACE/openwrt/feeds.conf.default"

  # for phicom n1
  # source code 404
  # git clone https://github.com/tuanqing/install-program "$GITHUB_WORKSPACE/openwrt/package/install-program"

  # replace release info
  sed -i -e '/exit 0/d' "$GITHUB_WORKSPACE/openwrt/package/default-settings/files/zzz-default-settings"
  {
    echo "sed -i '/BUILD_ID=/d' /usr/lib/os-release"
    echo "sed -i '/DISTRIB_REVISION=/d' /etc/openwrt_release"
    echo "sed -i '/DISTRIB_DESCRIPTION=/d' /etc/openwrt_release"
    echo "echo \"BUILD_ID=$R_VERSION\" >> /usr/lib/os-release"
    echo "echo \"DISTRIB_REVISION='$R_VERSION'\" >> /etc/openwrt_release"
    echo "echo \"DISTRIB_DESCRIPTION='$R_DESCRIPTION'\" >> /etc/openwrt_release"
    echo "exit 0"
  } >>"$GITHUB_WORKSPACE/openwrt/package/default-settings/files/zzz-default-settings"

  cd "$GITHUB_WORKSPACE/openwrt/"

  # feeds update
  ./scripts/feeds update -a

  # fix some luci-theme-bootstrap style issue
  {
    echo "#cbi-passwall-global .cbi-tabcontainer[data-tab=\"Main\"] select.cbi-input-select{width:auto;}"
    echo "#cbi-passwall-acl_rule .cbi-dropdown:not(.btn):not(.cbi-button),#cbi-passwall-acl_rule .cbi-dynlist{min-width:unset;}"
    echo "#list-content table{width:100%;}#list-content table tr td{height:30px;line-height:30px;}"
    echo "#cbi-passwall-nodes table td{text-align:left;}"
    echo "#cbi-passwall-nodes table td.cbi-section-actions input[type="checkbox"]{margin:6px;}"
    echo "#cbi-passwall-nodes table td.cbi-section-actions input[type="radio"]{margin:6px;}"
  } >>"$GITHUB_WORKSPACE/openwrt/feeds/luci/themes/luci-theme-bootstrap/htdocs/luci-static/bootstrap/cascade.css"

  TARGET_PASSWALL_CONFIG="$GITHUB_WORKSPACE/openwrt/feeds/diy1/luci-app-passwall/root/usr/share/passwall/"
  cat "$GITHUB_WORKSPACE/configs/pw-rules/0_default_config" >"$TARGET_PASSWALL_CONFIG/0_default_config"
  cat "$GITHUB_WORKSPACE/configs/pw-rules/block_host" >"$TARGET_PASSWALL_CONFIG/rules/block_host"
  cat "$GITHUB_WORKSPACE/configs/pw-rules/block_ip" >"$TARGET_PASSWALL_CONFIG/rules/block_ip"
  cat "$GITHUB_WORKSPACE/configs/pw-rules/direct_host" >"$TARGET_PASSWALL_CONFIG/rules/direct_host"
  cat "$GITHUB_WORKSPACE/configs/pw-rules/direct_ip" >"$TARGET_PASSWALL_CONFIG/rules/direct_ip"
  cat "$GITHUB_WORKSPACE/configs/pw-rules/lanlist_ipv4" >"$TARGET_PASSWALL_CONFIG/rules/lanlist_ipv4"
  cat "$GITHUB_WORKSPACE/configs/pw-rules/lanlist_ipv6" >"$TARGET_PASSWALL_CONFIG/rules/lanlist_ipv6"
  cat "$GITHUB_WORKSPACE/configs/pw-rules/proxy_host" >"$TARGET_PASSWALL_CONFIG/rules/proxy_host"
  cat "$GITHUB_WORKSPACE/configs/pw-rules/proxy_ip" >"$TARGET_PASSWALL_CONFIG/rules/proxy_ip"

  # feeds install
  ./scripts/feeds install -a
}

prepare_configs() {
  rm -rf "$GITHUB_WORKSPACE/openwrt/bin/targets/"
  rm -f "$GITHUB_WORKSPACE/openwrt/.config"
  rm -f "$GITHUB_WORKSPACE/openwrt/.config.old"
  cd "$GITHUB_WORKSPACE/openwrt/"

  echo "Read config $GITHUB_WORKSPACE/configs/$OPENWRT_CONFIG_FILE > $GITHUB_WORKSPACE/openwrt/.config"
  cat "$GITHUB_WORKSPACE/configs/$OPENWRT_CONFIG_FILE" >"$GITHUB_WORKSPACE/openwrt/.config"
  {
    cat "$GITHUB_WORKSPACE/configs/release-info.config"
    echo ""
    echo "CONFIG_VERSION_NUMBER=\"$(date +'v%y.%m.%d')\""
    echo ""
  } >>"$GITHUB_WORKSPACE/openwrt/.config"

  make defconfig
  # make download
  make download -j $(($(nproc) + 1))
}

echo "GITHUB_WORKSPACE=$GITHUB_WORKSPACE"

if [ -z "$OPENWRT_CONFIG_FILE" ]; then
  echo "OPENWRT_CONFIG_FILE not provide"
  exit 1
fi

echo "OPENWRT_CONFIG_FILE=$OPENWRT_CONFIG_FILE"

if [ "$REBUILD_FLAG" != "REBUILD" ]; then
  prepare_codes_feeds
fi

prepare_configs

exit 0
