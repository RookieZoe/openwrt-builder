# openwrt-builder

build custom openwrt with github actions

## lienol-19.07-luci19

![x86_64](https://github.com/RookieZoe/openwrt-builder/workflows/openwrt-19.07-x86_64/badge.svg)
![x86_64_with-samba](https://github.com/RookieZoe/openwrt-builder/workflows/openwrt-19.07-x86_64_with-samba/badge.svg)
![aarch64](https://github.com/RookieZoe/openwrt-builder/workflows/openwrt-19.07-aarch64/badge.svg)

Source Code: [Lienol/openwrt](https://github.com/Lienol/openwrt)

Feeds: ~~[openwrt-19.07.feeds](./openwrt-19.07.feeds)~~ Just change luci version from 17.01 to 19.07 ([code](https://github.com/RookieZoe/openwrt-builder/blob/main/.github/workflows/openwrt-19.07-x86_64.yml#L34))

x86_64_with-samba: [openwrt-19.07-x86_64_with-samba.config](./openwrt-19.07-x86_64_with-samba.config) (image only)

x86_64: [openwrt-19.07-x86_64.config](./openwrt-19.07-x86_64.config) (both docker && image)

aarch64: [openwrt-19.07-aarch64.config](./openwrt-19.07-aarch64.config) (both docker && image)

### luci app && package list

见 [wiki](https://github.com/RookieZoe/openwrt-builder/wiki)
