# openwrt-builder

build custom openwrt with github actions

## lienol/openwrt@22.03

[![x86_64](https://img.shields.io/github/actions/workflow/status/RookieZoe/openwrt-builder/openwrt-x86_64.yml?branch=main&color=34d058&label=x86_64&logo=github&logoColor=fff)](https://github.com/RookieZoe/openwrt-builder/actions/workflows/openwrt-x86_64.yml)
[openwrt-x86_64.config](./configs/x64.config)

[![aarch64](https://img.shields.io/github/actions/workflow/status/RookieZoe/openwrt-builder/openwrt-aarch64.yml?branch=main&color=34d058&label=aarch64&logo=github&logoColor=fff)](https://github.com/RookieZoe/openwrt-builder/actions/workflows/openwrt-aarch64.yml)
[openwrt-aarch64.config](./configs/arm8.config)

## ~~lienol/openwrt@21.02~~

~~openwrt-x86_64-samba4.config~~

## Thanks To

Source Code: [Lienol/openwrt](https://github.com/Lienol/openwrt)

n1 packing: [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)

### luci app && package list

见 [wiki](https://github.com/RookieZoe/openwrt-builder/wiki)

**重要说明：**

> 1. 使用 Release v22.09.22 之前固件安装的系统，在使用 img.gz 包更新系统之前，请仔细阅读 wiki。
> 2. 从 Release v22.12.20 开始，x86 固件启动方式变更为 UEFI，因此不支持直接升级，请备份配置，然后重装之后恢复配置。
> 3. 2023.03.13 更新，不再提供 samba 版本，可以使用 [iStoreOS](https://www.istoreos.com/) 代替，大团队维护，体验更佳。
