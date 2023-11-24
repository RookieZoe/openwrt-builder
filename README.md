# openwrt-builder

build custom openwrt with github actions

## openwrt/openwrt@openwrt-23.05

[![x86_64](https://img.shields.io/github/actions/workflow/status/RookieZoe/openwrt-builder/openwrt-x86_64.yml?branch=main&color=34d058&label=x86_64&logo=github&logoColor=fff)](https://github.com/RookieZoe/openwrt-builder/actions/workflows/openwrt-x86_64.yml)
[openwrt-x86_64.config](./configs/x64.config)

[![aarch64](https://img.shields.io/github/actions/workflow/status/RookieZoe/openwrt-builder/openwrt-aarch64.yml?branch=main&color=34d058&label=aarch64&logo=github&logoColor=fff)](https://github.com/RookieZoe/openwrt-builder/actions/workflows/openwrt-aarch64.yml)
[openwrt-aarch64.config](./configs/arm8.config)

## Thanks To

Source Code: [openwrt/openwrt](https://github.com/openwrt/openwrt)

Extra Apps1: [haiibo/openwrt-packages](https://github.com/haiibo/openwrt-packages)

Extra Apps2: [Lienol/openwrt-package](https://github.com/Lienol/openwrt-package)

luci-app-amlogic: [ophub/luci-app-amlogic](https://github.com/ophub/luci-app-amlogic)

pcat-manager from: [photonicat/pcat-manager](https://github.com/photonicat/rockchip_rk3568_openwrt/trunk/package/lean/pcat-manager)

arm op packing: [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)

### luci app && package list

see [configs](./configs/x64.config)

**重要说明：**

> 1. 2023.11.27 更新，更换为官方源码 openwrt-23.05 分支，iptables3 弃用，更换为 iptables4，自定义防火墙规则可能会不兼容，更新后需要重新设置。
