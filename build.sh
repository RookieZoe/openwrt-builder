git clone https://github.com/openwrt/openwrt.git -b openwrt-19.07 openwrt
echo 'src-git luci https://git.openwrt.org/project/luci.git;openwrt-19.07' > ./openwrt/feeds.conf.default
echo 'src-git routing https://git.openwrt.org/feed/routing.git;openwrt-19.07' >> ./openwrt/feeds.conf.default
echo 'src-git packages https://git.openwrt.org/feed/packages.git;openwrt-19.07' >> ./openwrt/feeds.conf.default
echo 'src-git telephony https://git.openwrt.org/feed/telephony.git;openwrt-19.07' >> ./openwrt/feeds.conf.default
echo 'src-git lienol https://github.com/Lienol/openwrt-package.git' >> ./openwrt/feeds.conf.default
echo 'src-git small https://github.com/kenzok8/small.git' >> ./openwrt/feeds.conf.default
echo 'src-git kenzo https://github.com/kenzok8/openwrt-packages.git' >> ./openwrt/feeds.conf.default

cd openwrt/
./scripts/feeds update -a
./scripts/feeds install -a

cp .config ./openwrt/.config
make download

make
