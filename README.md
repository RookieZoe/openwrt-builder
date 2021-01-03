# openwrt-builder

build custom openwrt with github actions

## lienol-19.07-luci19

![x86_64](https://github.com/RookieZoe/openwrt-builder/workflows/openwrt-19.07-x86_64/badge.svg)
![arm64](https://github.com/RookieZoe/openwrt-builder/workflows/openwrt-19.07-arm64/badge.svg)

Source Code: [Lienol/openwrt](https://github.com/Lienol/openwrt)

Feeds: ~~[openwrt-19.07.feeds](./openwrt-19.07.feeds)~~ Just change luci version from 17.01 to 19.07 ([code](https://github.com/RookieZoe/openwrt-builder/blob/main/.github/workflows/openwrt-19.07-x86_64.yml#L33))

x86_64: [openwrt-19.07-x86_64.config](./openwrt-19.07-x86_64.config)

arm64: [openwrt-19.07-arm64.config](./openwrt-19.07-arm64.config)

n1 img maker: [tuanqing/mknop](https://github.com/tuanqing/mknop)

### luci app list

- luci-app-adbyby-plus
- luci-app-arpbind
- luci-app-ddns (arm64)
- luci-app-fileassistant
- luci-app-firewall
- luci-app-hd-idle
- luci-app-diskman (x86_64)
- luci-app-netdata
- luci-app-openvpn (arm64)
- luci-app-openvpn-server (arm64)
- luci-app-opkg
- luci-app-passwall
- luci-app-ramfree
- luci-app-samba (arm64)
- luci-app-samba4 (x86_64)
- luci-app-sfe
- luci-app-smartdns
- luci-app-unblockmusic
- luci-app-vlmcsd
- luci-app-zerotier
