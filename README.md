# OpenWrt Image Builder

使用 GitHub Actions 构建 x86-64 的 OpenWrt 或 ImmortalWrt 固件。手动运行 **OpenWrt Image Builder** 时，发行版默认为 OpenWrt，网络 profile 默认为 `single-arm`；版本输入框可选，留空会自动获取对应发布目录中最高的稳定版本，填写如 `24.10.5` 则构建该精确版本。工作流每周一北京时间 03:00 自动构建最新 OpenWrt 的单臂 profile，并校验下载文件的官方 SHA-256。

## 自定义内容

- [`openwrt/add_packages`](openwrt/add_packages) 用于 OpenWrt 的预装软件包。
- [`openwrt/add_packages_immortal`](openwrt/add_packages_immortal) 用于 ImmortalWrt 的预装软件包。
- [`openwrt/del_packages`](openwrt/del_packages) 指定从默认镜像移除的软件包。
- [`scripts/modify-imagebuilder-config.sh`](scripts/modify-imagebuilder-config.sh) 调整 ImageBuilder 的 x86 根分区、GRUB 与优化选项。
- [`openwrt/profiles/single-arm`](openwrt/profiles/single-arm) 是默认 profile：保留默认 `br-lan → eth0`，LAN 使用 DHCP/DHCPv6 客户端模式，适合终端与上级路由位于同一二层网络的旁路由。只需要一张 PVE VirtIO 网卡。
- [`openwrt/profiles/standard`](openwrt/profiles/standard) 使用 `eth0` WAN DHCP/DHCPv6 与 `br-lan → eth1` 静态 LAN，向终端提供 DHCP、RA 和 DHCPv6 服务。需要两张 PVE VirtIO 网卡。
- [`openwrt/uci-defaults`](openwrt/uci-defaults) 包含两个 profile 共用的系统和软件源配置：`30-system` 设置主机名、时区和 NTP，`40-repositories` 在 APK 源配置存在时切换到中科大镜像。它们按文件名顺序执行并在成功后删除。
- [`openwrt/files/etc/sysctl.d/99-custom.conf`](openwrt/files/etc/sysctl.d/99-custom.conf) 直接植入内核网络性能参数，不依赖首次启动脚本。
- [`scripts/resolve-imagebuilder.sh`](scripts/resolve-imagebuilder.sh) 解析版本、下载、校验并解压 ImageBuilder。
- [`scripts/prepare-packages.sh`](scripts/prepare-packages.sh) 清理、去重并导出软件包清单。
- [`scripts/collect-artifacts.sh`](scripts/collect-artifacts.sh) 收集固件、校验和与构建元数据。

构建产物包含固件 SHA-256、ImageBuilder manifest、选择的软件包列表、仓库提交和构建时间，便于复现。

## PVE 网卡映射

| PVE 虚拟网卡 | OpenWrt 接口 | 用途 |
| --- | --- | --- |
| `single-arm`: `eth0` | `br-lan` → `lan` | DHCP/DHCPv6，上游默认路由、终端网关与管理访问 |
| `standard`: `eth0` | `wan` | DHCP/DHCPv6，上游默认路由 |
| `standard`: `eth1` | `br-lan` → `lan` | 静态 `192.168.20.1/24`，终端网络、DHCP、RA、DHCPv6 |

官方自定义文件说明：https://openwrt.org/docs/guide-user/additional-software/imagebuilder#custom_files
