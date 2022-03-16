# openwrt-builder

build custom openwrt with github actions

## lienol-21.02-luci19

[![openwrt-21.02](https://img.shields.io/github/workflow/status/RookieZoe/openwrt-builder/openwrt-21.02?color=34d058&label=openwrt&logo=github&logoColor=fff)](https://github.com/RookieZoe/openwrt-builder/actions/workflows/openwrt-21.02.yml)

[![openwrt-21.02-aarch64](https://img.shields.io/github/workflow/status/RookieZoe/openwrt-builder/openwrt-21.02-aarch64?color=34d058&label=openwrt&logo=github&logoColor=fff)](https://github.com/RookieZoe/openwrt-builder/actions/workflows/openwrt-21.02-aarch64.yml)

Source Code: [Lienol/openwrt](https://github.com/Lienol/openwrt)

Feeds: ~~openwrt-21.02.feeds~~ Just change luci version from 21.02 to 19.07 ([code](https://github.com/RookieZoe/openwrt-builder/blob/21.02/scripts/prebuild.bash#L34))

x86_64: [openwrt-21.02-x86_64.config](./configs/openwrt-21.02-x86_64-full.config)

### luci app && package list

见 [wiki](https://github.com/RookieZoe/openwrt-builder/wiki)
