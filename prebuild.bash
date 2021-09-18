#!/bin/bash
set -e

WORK_DIR=$(cd $(dirname $0); pwd)
GITHUB_WORKSPACE=${GITHUB_WORKSPACE:-$WORK_DIR}
OPENWRT_CONFIG_FILE=${OPENWRT_CONFIG_FILE:-}

R_VERSION=$(date +'v%y.%m.%d')
R_DESCRIPTION="OpenWrt "$R_VERSION" Build by Rookie_Zoe"

echo "GITHUB_WORKSPACE="$GITHUB_WORKSPACE

if [ -z $OPENWRT_CONFIG_FILE ]; then
  echo "OPENWRT_CONFIG_FILE not provide"
  exit 1
fi

echo "OPENWRT_CONFIG_FILE="$OPENWRT_CONFIG_FILE

# pull openwrt source code
rm -rf $GITHUB_WORKSPACE/openwrt
git clone -b 19.07 --single-branch https://github.com/Lienol/openwrt.git $GITHUB_WORKSPACE/openwrt

cd $GITHUB_WORKSPACE/openwrt/

# replace luci:17.01 with luci:19.07
sed -i -e '/openwrt-luci.git;17.01/d' $GITHUB_WORKSPACE/openwrt/feeds.conf.default
echo "" >> $GITHUB_WORKSPACE/openwrt/feeds.conf.default
echo "src-git luci https://github.com/Lienol/openwrt-luci.git;19.07" >> $GITHUB_WORKSPACE/openwrt/feeds.conf.default
echo "src-git diy1 https://github.com/xiaorouji/openwrt-passwall.git;main" >> $GITHUB_WORKSPACE/openwrt/feeds.conf.default

# replace release info
sed -i -e '/exit 0/d' $GITHUB_WORKSPACE/openwrt/package/default-settings/files/zzz-default-settings
echo "sed -i '/BUILD_ID=/d' /usr/lib/os-release" >>$GITHUB_WORKSPACE/openwrt/package/default-settings/files/zzz-default-settings
echo "sed -i '/DISTRIB_REVISION=/d' /etc/openwrt_release" >>$GITHUB_WORKSPACE/openwrt/package/default-settings/files/zzz-default-settings
echo "sed -i '/DISTRIB_DESCRIPTION=/d' /etc/openwrt_release" >>$GITHUB_WORKSPACE/openwrt/package/default-settings/files/zzz-default-settings
echo "echo \"BUILD_ID=\\\"$R_VERSION\\\"\" >> /usr/lib/os-release" >>$GITHUB_WORKSPACE/openwrt/package/default-settings/files/zzz-default-settings
echo "echo \"DISTRIB_REVISION='$R_VERSION'\" >> /etc/openwrt_release" >>$GITHUB_WORKSPACE/openwrt/package/default-settings/files/zzz-default-settings
echo "echo \"DISTRIB_DESCRIPTION='$R_DESCRIPTION'\" >> /etc/openwrt_release" >>$GITHUB_WORKSPACE/openwrt/package/default-settings/files/zzz-default-settings
echo "exit 0" >>$GITHUB_WORKSPACE/openwrt/package/default-settings/files/zzz-default-settings

# feeds update
./scripts/feeds update -a

# fix some luci-theme-bootstrap style issue
cat >> $GITHUB_WORKSPACE/openwrt/feeds/luci/themes/luci-theme-bootstrap/htdocs/luci-static/bootstrap/cascade.css << EOF
#cbi-passwall-global .cbi-tabcontainer[data-tab="Main"] select.cbi-input-select{width:auto;}
#cbi-passwall-acl_rule .cbi-dropdown:not(.btn):not(.cbi-button),#cbi-passwall-acl_rule .cbi-dynlist{min-width:unset;}
#list-content table{width:100%;}#list-content table tr td{height:30px;line-height:30px;}
EOF

# feeds install
./scripts/feeds install -a

# make defconfig
rm -f $GITHUB_WORKSPACE/openwrt/.config
rm -f $GITHUB_WORKSPACE/openwrt/.config.old
cp $GITHUB_WORKSPACE/configs/$OPENWRT_CONFIG_FILE $GITHUB_WORKSPACE/openwrt/.config
echo "" >> $GITHUB_WORKSPACE/openwrt/.config
cat $GITHUB_WORKSPACE/configs/release-info.config >> $GITHUB_WORKSPACE/openwrt/.config
echo "" >> $GITHUB_WORKSPACE/openwrt/.config
echo "CONFIG_VERSION_NUMBER=\"$(date +'v%y.%m.%d')\"">> $GITHUB_WORKSPACE/openwrt/.config

make defconfig

# make download
make download -j$(nproc)
find dl -size -1024c -exec ls -l {} \;
find dl -size -1024c -exec rm -f {} \;

exit 0