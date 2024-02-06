#!/usr/bin/env bash
echo ">>>>>>>>>>>>>>> Install tools chain which depends by building OpenWrt"
sudo -E apt-get -qq update
sudo -E apt-get -qq install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf tree curl gcc-10 g++-10
sudo -E update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100
sudo -E update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100

echo ">>>>>>>>>>>>>>> Listing disk space information after tools chain installed."
df -h
