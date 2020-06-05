sudo apt-get update
sudo apt-get -y install \
build-essential \
asciidoc \
binutils \
bzip2 \
gawk \
gettext \
git \
libncurses5-dev \
libz-dev \
patch \
python3.5 \
python2.7 \
unzip \
zlib1g-dev \
lib32gcc1 \
libc6-dev-i386 \
subversion \
flex \
uglifyjs \
git-core \
gcc-multilib \
p7zip \
p7zip-full \
msmtp \
libssl-dev \
texinfo \
libglib2.0-dev \
xmlto \
qemu-utils \
upx \
libelf-dev \
autoconf \
automake \
libtool \
autopoint \
device-tree-compiler \
g++-multilib \
antlr3 \
gperf

git clone https://github.com/openwrt/openwrt.git

echo 'src-git packages https://git.openwrt.org/feed/packages.git' > ./openwrt/feeds.conf.default
echo 'src-git luci https://git.openwrt.org/project/luci.git' >> ./openwrt/feeds.conf.default
echo 'src-git routing https://git.openwrt.org/feed/routing.git' >> ./openwrt/feeds.conf.default
echo 'src-git telephony https://git.openwrt.org/feed/telephony.git' >> ./openwrt/feeds.conf.default
echo 'src-git lienol https://github.com/Lienol/openwrt-package.git' >> ./openwrt/feeds.conf.default
echo 'src-git small https://github.com/kenzok8/small.git' >> ./openwrt/feeds.conf.default
echo 'src-git kenzo https://github.com/kenzok8/openwrt-packages.git' >> ./openwrt/feeds.conf.default

git clone https://github.com/rufengsuixing/luci-app-zerotier.git
mv luci-app-zerotier ./openwrt/package
git clone https://github.com/awesome-openwrt/luci-app-vlmcsd.git
mv luci-app-vlmcsd ./openwrt/package
git clone https://github.com/frainzy1477/luci-app-clash.git
mv luci-app-clash ./openwrt/package
git clone https://github.com/coolsnowwolf/lede.git
mv lede/package/lean/vlmcsd ./openwrt/package/

cd openwrt/
./scripts/feeds update -a
./scripts/feeds install -a

cp .config ./openwrt/.config
make download

make
