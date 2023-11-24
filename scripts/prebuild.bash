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

OPENWRT_SOURCE="https://github.com/openwrt/openwrt.git"
OPENWRT_BRANCH="openwrt-23.05"
PASSWALL_BRANCH="branches/luci-smartdns-dev"

PUB_CONF_PATH="$GITHUB_WORKSPACE/public"
ARCH_CONF_PATH="$GITHUB_WORKSPACE/configs"

turboacc_patch() {
  K_VERSION=''
  case "$OPENWRT_BRANCH" in
  'openwrt-22.03')
    K_VERSION="5.10"
    ;;
  'openwrt-23.05')
    K_VERSION="5.15"
    ;;
  'main')
    K_VERSION="6.1"
    ;;
  esac

  # if K_VERSION is not empty, then patch turboacc
  if [ -n "$K_VERSION" ]; then
    pushd "$GITHUB_WORKSPACE/openwrt"

    mkdir -p turboacc_tmp ./package/turboacc
    git clone --depth 1 https://github.com/chenmozhijin/turboacc -b package ./turboacc_tmp/turboacc
    git clone --depth 1 https://github.com/fullcone-nat-nftables/nft-fullcone ./package/turboacc/nft-fullcone
    git clone --depth 1 https://github.com/chenmozhijin/turboacc -b luci ./package/turboacc/turboacc
    mv ./package/turboacc/turboacc/luci-app-turboacc ./package/turboacc/luci-app-turboacc
    rm -rf ./package/turboacc/turboacc

    if [ "$K_VERSION" = "5.10" ]; then
      cp -f turboacc_tmp/turboacc/hack-$K_VERSION/952-net-conntrack-events-support-multiple-registrant.patch ./target/linux/generic/hack-$K_VERSION/952-net-conntrack-events-support-multiple-registrant.patch
      cp -f turboacc_tmp/turboacc/hack-$K_VERSION/953-net-patch-linux-kernel-to-support-shortcut-fe.patch ./target/linux/generic/hack-$K_VERSION/953-net-patch-linux-kernel-to-support-shortcut-fe.patch
      cp -f turboacc_tmp/turboacc/pending-$K_VERSION/613-netfilter_optional_tcp_window_check.patch ./target/linux/generic/hack-$K_VERSION/613-netfilter_optional_tcp_window_check.patch
    else
      cp -f turboacc_tmp/turboacc/hack-$K_VERSION/952-add-net-conntrack-events-support-multiple-registrant.patch ./target/linux/generic/hack-$K_VERSION/952-add-net-conntrack-events-support-multiple-registrant.patch
      cp -f turboacc_tmp/turboacc/hack-$K_VERSION/953-net-patch-linux-kernel-to-support-shortcut-fe.patch ./target/linux/generic/hack-$K_VERSION/953-net-patch-linux-kernel-to-support-shortcut-fe.patch
      cp -f turboacc_tmp/turboacc/pending-$K_VERSION/613-netfilter_optional_tcp_window_check.patch ./target/linux/generic/pending-$K_VERSION/613-netfilter_optional_tcp_window_check.patch
    fi

    rm -rf ./package/libs/libnftnl ./package/network/config/firewall4 ./package/network/utils/nftables
    mkdir -p ./package/network/config/firewall4 ./package/libs/libnftnl ./package/network/utils/nftables
    cp -r ./turboacc_tmp/turboacc/shortcut-fe ./package/turboacc
    cp -RT "./turboacc_tmp/turboacc/firewall4-$(grep -o 'FIREWALL4_VERSION=.*' ./turboacc_tmp/turboacc/version | cut -d '=' -f 2)/firewall4" ./package/network/config/firewall4
    cp -RT "./turboacc_tmp/turboacc/libnftnl-$(grep -o 'LIBNFTNL_VERSION=.*' ./turboacc_tmp/turboacc/version | cut -d '=' -f 2)/libnftnl" ./package/libs/libnftnl
    cp -RT "./turboacc_tmp/turboacc/nftables-$(grep -o 'NFTABLES_VERSION=.*' ./turboacc_tmp/turboacc/version | cut -d '=' -f 2)/nftables" ./package/network/utils/nftables
    rm -rf turboacc_tmp
    echo "# CONFIG_NF_CONNTRACK_CHAIN_EVENTS is not set" >>"target/linux/generic/config-$K_VERSION"
    echo "# CONFIG_SHORTCUT_FE is not set" >>"target/linux/generic/config-$K_VERSION"

    popd
  fi
}

prepare_codes_feeds() {
  echo ">>>>>>>>>>>>>>>>> Prepare source codes and feeds"
  # pull openwrt source code
  rm -rf "$GITHUB_WORKSPACE/openwrt"
  git clone --depth 1 "$OPENWRT_SOURCE" -b "$OPENWRT_BRANCH" "$GITHUB_WORKSPACE/openwrt"

  cd "$GITHUB_WORKSPACE/openwrt/"

  turboacc_patch

  # feeds update
  echo ">>>>>>>>>>>>>>>>> feeds update"
  ./scripts/feeds update -a

  mkdir -p package/diy1

  echo ">>>>>>>>>>>>>>>>> add extra packages from [github.com/haiibo/openwrt-packages]"
  svn co https://github.com/haiibo/openwrt-packages/trunk/adguardhome package/diy1/adguardhome
  svn co https://github.com/haiibo/openwrt-packages/trunk/luci-app-adguardhome package/diy1/luci-app-adguardhome
  svn co https://github.com/haiibo/openwrt-packages/trunk/luci-app-netdata package/diy1/luci-app-netdata

  echo ">>>>>>>>>>>>>>>>> add extra packages from [github.com/Lienol/openwrt-package]"
  svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-fileassistant package/diy1/luci-app-fileassistant
  svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-ramfree package/diy1/luci-app-ramfree
  svn co https://github.com/Lienol/openwrt-package/branches/other/lean/vlmcsd package/diy1/vlmcsd
  svn co https://github.com/Lienol/openwrt-package/branches/other/lean/luci-app-arpbind package/diy1/luci-app-arpbind
  svn co https://github.com/Lienol/openwrt-package/branches/other/lean/luci-app-vlmcsd package/diy1/luci-app-vlmcsd
  svn co https://github.com/Lienol/openwrt-package/branches/other/lean/luci-app-zerotier package/diy1/luci-app-zerotier

  echo ">>>>>>>>>>>>>>>>> add luci-app-amlogic from [github.com/ophub/luci-app-amlogic]"
  svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/diy1/luci-app-amlogic

  echo ">>>>>>>>>>>>>>>>> add pcat-manager from [https://github.com/photonicat/rockchip_rk3568_openwrt]"
  svn co https://github.com/photonicat/rockchip_rk3568_openwrt/trunk/package/lean/pcat-manager package/diy1/pcat-manager

  echo ">>>>>>>>>>>>>>>>> add luci-app-passwall from [github.com/xiaorouji/openwrt-passwall]"
  git clone --depth 1 https://github.com/xiaorouji/openwrt-passwall-packages.git -b main package/diy1/openwrt-passwall
  svn co "https://github.com/xiaorouji/openwrt-passwall/$PASSWALL_BRANCH/luci-app-passwall" package/diy1/luci-app-passwall

  # set luci-app-passwall rules
  echo ">>>>>>>>>>>>>>>>> set luci-app-passwall rules"
  TARGET_PASSWALL_CONFIG="$GITHUB_WORKSPACE/openwrt/package/diy1/luci-app-passwall/root/usr/share/passwall/"
  cat "$PUB_CONF_PATH/pw-rules/0_default_config/"* >"$TARGET_PASSWALL_CONFIG/0_default_config"
  cat "$PUB_CONF_PATH/pw-rules/block_host" >"$TARGET_PASSWALL_CONFIG/rules/block_host"
  cat "$PUB_CONF_PATH/pw-rules/block_ip" >"$TARGET_PASSWALL_CONFIG/rules/block_ip"
  cat "$PUB_CONF_PATH/pw-rules/direct_host" >"$TARGET_PASSWALL_CONFIG/rules/direct_host"
  cat "$PUB_CONF_PATH/pw-rules/direct_ip" >"$TARGET_PASSWALL_CONFIG/rules/direct_ip"
  cat "$PUB_CONF_PATH/pw-rules/lanlist_ipv4" >"$TARGET_PASSWALL_CONFIG/rules/lanlist_ipv4"
  cat "$PUB_CONF_PATH/pw-rules/lanlist_ipv6" >"$TARGET_PASSWALL_CONFIG/rules/lanlist_ipv6"
  cat "$PUB_CONF_PATH/pw-rules/proxy_host" >"$TARGET_PASSWALL_CONFIG/rules/proxy_host"
  cat "$PUB_CONF_PATH/pw-rules/proxy_ip" >"$TARGET_PASSWALL_CONFIG/rules/proxy_ip"

  echo ">>>>>>>>>>>>>>>>> replace feeds/packages/net/xray-core with package/diy1/xray-core"
  rm -rf feeds/packages/net/xray-core
  cp -r package/diy1/openwrt-passwall/xray-core feeds/packages/net

  # fix some luci-theme-bootstrap style issue
  echo ">>>>>>>>>>>>>>>>> fix some luci-theme-bootstrap style issue"
  LUCI_THEME_BOOTSTRAP_FILE="$GITHUB_WORKSPACE/openwrt/feeds/luci/themes/luci-theme-bootstrap/htdocs/luci-static/bootstrap/cascade.css"
  sed -i -e 's/940px/1100px/g' "$LUCI_THEME_BOOTSTRAP_FILE"
  cat "$PUB_CONF_PATH/luci-theme-bootstrap/cascade.css" >>"$LUCI_THEME_BOOTSTRAP_FILE"

  # make luci-app-ttyd height fit window
  echo ">>>>>>>>>>>>>>>>> make luci-app-ttyd height fit window"
  LUCI_TTYD_TERMJS="$GITHUB_WORKSPACE/openwrt/feeds/luci/applications/luci-app-ttyd/htdocs/luci-static/resources/view/ttyd/term.js"
  sed -i -e 's/500px/calc(100vh - 173px)/g' "$LUCI_TTYD_TERMJS"

  # feeds install
  echo ">>>>>>>>>>>>>>>>> feeds install"
  ./scripts/feeds install -a
}

prepare_configs() {
  echo ">>>>>>>>>>>>>>>>> Prepare config"
  cd "$GITHUB_WORKSPACE"
  # git checkout ./

  cd "$GITHUB_WORKSPACE/openwrt/"
  rm -rf "$GITHUB_WORKSPACE/openwrt/bin/targets/"
  rm -f "$GITHUB_WORKSPACE/openwrt/.config"
  rm -f "$GITHUB_WORKSPACE/openwrt/.config.old"

  echo ">>>>>>>>>>>>>>>>> Read config $1 > $GITHUB_WORKSPACE/openwrt/.config"
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
